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
    required String description,
    required List<File> imageFiles,
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

      await _client.from('requests').insert({
        'customer_id': userId,
        'category_id': categoryId,
        'description': description,
        'images': imageUrls,
        'status': 'Pending_Broadcast',
      });

    } catch (e) {
      state = false;
      throw e;
    }
    state = false;
  }

  Future<void> submitBid({
    required String requestId,
    required double price,
  }) async {
    state = true;
    try {
      final userId = _client.auth.currentUser!.id;
      
      // Calculate net profit (assuming 10% commission for now)
      final double netProfit = price * 0.90;

      await _client.from('bids').insert({
        'request_id': requestId,
        'provider_id': userId,
        'price': price,
        'net_profit': netProfit,
        'status': 'Pending',
      });

    } catch (e) {
      state = false;
      throw e;
    }
    state = false;
  }

  Future<void> rejectBid(String bidId, String providerId, String requestId) async {
    state = true;
    try {
      final customerId = _client.auth.currentUser!.id;

      // 1. Update bid status
      await _client.from('bids').update({'status': 'Rejected'}).eq('id', bidId);

      // 2. Add temporary block for 24 hours
      final expiresAt = DateTime.now().add(const Duration(hours: 24));
      await _client.from('temporary_blocks').insert({
        'customer_id': customerId,
        'provider_id': providerId,
        'request_id': requestId,
        'expires_at': expiresAt.toIso8601String(),
      });

    } catch (e) {
      state = false;
      throw e;
    }
    state = false;
  }

  Future<void> acceptBid(String bidId, String requestId, String providerId, double price) async {
    state = true;
    try {
      // Call the RPC to handle the entire transaction securely
      await _client.rpc('accept_bid_and_lock_escrow', params: {
        'p_bid_id': bidId,
        'p_request_id': requestId,
        'p_provider_id': providerId,
        'p_total_amount': price,
      });

    } catch (e) {
      state = false;
      throw e;
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
    final profileRes = await supabase.from('profiles').select('is_premium').eq('id', userId).maybeSingle();
    final isPremium = profileRes?['is_premium'] == true;

    sub = supabase
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('category_id', categoryId)
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
            final createdAt = DateTime.parse(req['created_at']);
            if (now.difference(createdAt).inSeconds >= 5) {
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
    });
  }

  init();

  ref.onDispose(() {
    sub?.cancel();
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

// Stream provider to fetch bids for a customer's specific request
final requestBidsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, requestId) {
  final supabase = Supabase.instance.client;
  
  return supabase
      .from('bids')
      .stream(primaryKey: ['id'])
      .eq('request_id', requestId)
      .order('price', ascending: true); // Order by price lowest first
});

// Future provider to get provider details for a bid
final bidProviderDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, providerId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('profiles').select('full_name, avatar_url, is_premium, is_fast, is_clean').eq('id', providerId).single();
  return response;
});
