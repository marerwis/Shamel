import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

class ChatModel {
  final String id;
  final String? orderId;
  final String customerId;
  final String providerId;
  final DateTime createdAt;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? provider;
  final List<MessageModel> recentMessages;

  ChatModel({
    required this.id,
    this.orderId,
    required this.customerId,
    required this.providerId,
    required this.createdAt,
    this.customer,
    this.provider,
    this.recentMessages = const [],
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    List<MessageModel> messages = [];
    if (json['messages'] != null) {
      messages = (json['messages'] as List).map((m) => MessageModel.fromJson(m)).toList();
    }

    return ChatModel(
      id: json['id'],
      orderId: json['order_id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      createdAt: DateTime.parse(json['created_at']),
      customer: json['customer'],
      provider: json['provider'],
      recentMessages: messages,
    );
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

final chatsListProvider = AsyncNotifierProvider<ChatsListNotifier, List<ChatModel>>(() {
  return ChatsListNotifier();
});

class ChatsListNotifier extends AsyncNotifier<List<ChatModel>> {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  FutureOr<List<ChatModel>> build() async {
    return _fetchChats();
  }

  Future<List<ChatModel>> _fetchChats() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return [];

    final isProvider = user.role == 'provider';

    final response = await _client
        .from('chats')
        .select('''
          *,
          customer:profiles!chats_customer_id_fkey(id, full_name, avatar_url),
          provider:profiles!chats_provider_id_fkey(id, full_name, avatar_url),
          messages(id, chat_id, sender_id, content, is_read, created_at)
        ''')
        .eq(isProvider ? 'provider_id' : 'customer_id', user.id)
        .order('created_at', ascending: false)
        .order('created_at', referencedTable: 'messages', ascending: false)
        .limit(1, referencedTable: 'messages'); // Get only last message for preview

    return (response as List).map((data) => ChatModel.fromJson(data)).toList();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchChats());
  }

  Future<String?> createOrGetChat({required String otherUserId, String? orderId}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final customerId = user.role == 'provider' ? otherUserId : user.id;
    final providerId = user.role == 'provider' ? user.id : otherUserId;

    // Check if chat already exists
    var query = _client.from('chats').select('id').eq('customer_id', customerId).eq('provider_id', providerId);
    if (orderId != null) {
      query = query.eq('order_id', orderId);
    } else {
      query = query.is_('order_id', null);
    }
    
    final existing = await query.maybeSingle();

    if (existing != null) {
      return existing['id'];
    }

    // Create new chat
    try {
      final response = await _client.from('chats').insert({
        'customer_id': customerId,
        'provider_id': providerId,
        if (orderId != null) 'order_id': orderId,
      }).select('id').single();
      
      await refresh();
      return response['id'];
    } catch (e) {
      print('Error creating chat: $e');
      return null;
    }
  }
}

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  final client = Supabase.instance.client;
  return client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('chat_id', chatId)
      .order('created_at', ascending: true)
      .map((list) => list.map((m) => MessageModel.fromJson(m)).toList());
});

final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController(ref);
});

class ChatController {
  final Ref ref;
  final SupabaseClient _client = Supabase.instance.client;

  ChatController(this.ref);

  Future<bool> sendMessage(String chatId, String content) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      await _client.from('messages').insert({
        'chat_id': chatId,
        'sender_id': user.id,
        'content': content,
      });
      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }
}
