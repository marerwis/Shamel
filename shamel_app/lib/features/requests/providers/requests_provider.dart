import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

final requestsProvider = StateNotifierProvider<RequestsNotifier, bool>((ref) {
  return RequestsNotifier();
});

class RequestsNotifier extends StateNotifier<bool> {
  RequestsNotifier() : super(false);

  final _client = Supabase.instance.client;

  Future<void> createRequest({
    required String categoryId,
    String? serviceId,
    required String description,
    required List<File> imageFiles,
    double price = 0,
    String? address,
    DateTime? scheduledAt,
    String? notes,
  }) async {
    state = true;
    try {
      final userId = _client.auth.currentUser!.id;
      List<String> imageUrls = [];

      for (var file in imageFiles) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final storagePath = '$userId/$fileName';
        
        try {
          await _client.storage.from('request_images').upload(storagePath, file);
          final url = _client.storage.from('request_images').getPublicUrl(storagePath);
          imageUrls.add(url);
        } catch (e) {
          print('Error uploading image: $e');
        }
      }
      
      String targetCategoryId = categoryId;
      try {
        final catRes = await _client.from('categories').select('parent_id').eq('id', categoryId).maybeSingle();
        if (catRes != null && catRes['parent_id'] != null) {
          targetCategoryId = catRes['parent_id'];
        }
      } catch (_) {}

      if (price > 0) {
        await _client.rpc('process_wallet_transaction', params: {
          'p_user_id': userId,
          'p_amount': price,
          'p_transaction_type': 'debit',
          'p_description': 'دفع قيمة الطلب لخدمة التوصيل'
        });
      }

      await _client.from('requests').insert({
        'user_id': userId,
        'category_id': targetCategoryId,
        'service_id': serviceId,
        'description': description,
        'images': imageUrls,
        'price': price,
        'status': 'Pending_Broadcast',
        'address': address,
        'scheduled_at': scheduledAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'notes': notes,
      });

    } on PostgrestException catch (e) {
      state = false;
      throw Exception('خطأ في قاعدة البيانات: ${e.message}');
    } catch (e) {
      state = false;
      throw Exception('حدث خطأ غير متوقع: $e');
    }
    state = false;
  }

  Future<void> acceptRequestDirectly(String requestId) async {
    state = true;
    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client.rpc('accept_direct_request', params: {
        'p_request_id': requestId,
        'p_provider_id': userId,
      });
      if (response == false) {
        throw Exception('عذراً، لقد تم قبول هذا الطلب من قبل مزود آخر.');
      }
    } on PostgrestException catch (e) {
      state = false;
      throw Exception('خطأ في قاعدة البيانات: ${e.message}');
    } catch (e) {
      state = false;
      throw Exception('حدث خطأ غير متوقع: $e');
    }
    state = false;
  }
}

// Stream provider to fetch active requests for a provider's category
final providerRequestsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, categoryId) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) return Stream.value([]);

  final controller = StreamController<List<Map<String, dynamic>>>();
  StreamSubscription? sub;
  Timer? timer;

  Future<void> init() async {
    try {
      // 1. Check if provider is busy
      final activeOrders = await supabase.from('orders').select('id')
        .eq('provider_id', userId)
        .inFilter('status', ['pending', 'in_progress', 'accepted']);
      
      if (activeOrders.isNotEmpty) {
        controller.add([]);
        return; // Provider is busy, do not listen to new requests
      }

      final profileRes = await supabase.from('profiles').select('is_premium').eq('id', userId).maybeSingle();
      final isPremium = profileRes?['is_premium'] == true;

      sub = supabase
          .from('requests')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .listen((allRequests) {
        
        final requests = allRequests.where((r) => r['status'] == 'Pending_Broadcast').toList();      
        if (isPremium) {
          controller.add(requests);
        } else {
          void emitFiltered() {
            final now = DateTime.now();
            bool hasDelayed = false;
            final filtered = requests.where((req) {
              final createdAtRaw = req['created_at'];
              final createdAt = createdAtRaw != null ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now() : DateTime.now();
              if (now.difference(createdAt).inSeconds >= 5) {
                hasDelayed = true;
                return true;
              } else {
                hasDelayed = true;
                return false;
              }
            }).toList();
            
            controller.add(filtered);
            
            if (hasDelayed) {
              timer?.cancel();
              timer = Timer(const Duration(seconds: 1), emitFiltered);
            }
          }
          
          emitFiltered();
        }
      }, onError: (error) {
        if (!controller.isClosed) controller.addError(error);
      });
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    }
  }

  init();

  ref.onDispose(() {
    sub?.cancel();
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

// Removed bidding providers

// FutureProvider to fetch customer's own requests (avoids WebSocket Realtime errors)
final myRequestsStreamProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) return [];
  
  final res = await supabase
      .from('requests')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  
  return List<Map<String, dynamic>>.from(res);
});

