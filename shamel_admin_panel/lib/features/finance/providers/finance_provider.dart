import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminWalletProvider = FutureProvider<double>((ref) async {
  final response = await Supabase.instance.client
      .from('admin_wallet')
      .select('total_revenue')
      .limit(1)
      .maybeSingle();
      
  if (response == null) return 0.0;
  return (response['total_revenue'] as num).toDouble();
});

class WithdrawalRequestAdminModel {
  final String id;
  final String providerId;
  final num amount;
  final String status;
  final String bankName;
  final String iban;
  final DateTime createdAt;
  final String? providerName;

  WithdrawalRequestAdminModel({
    required this.id,
    required this.providerId,
    required this.amount,
    required this.status,
    required this.bankName,
    required this.iban,
    required this.createdAt,
    this.providerName,
  });

  factory WithdrawalRequestAdminModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequestAdminModel(
      id: json['id'],
      providerId: json['provider_id'],
      amount: json['amount'],
      status: json['status'],
      bankName: json['bank_name'],
      iban: json['iban'],
      createdAt: DateTime.parse(json['created_at']),
      providerName: json['provider'] != null ? json['provider']['full_name'] : null,
    );
  }
}

final financeRequestsProvider = AsyncNotifierProvider<FinanceRequestsNotifier, List<WithdrawalRequestAdminModel>>(() {
  return FinanceRequestsNotifier();
});

class FinanceRequestsNotifier extends AsyncNotifier<List<WithdrawalRequestAdminModel>> {
  @override
  FutureOr<List<WithdrawalRequestAdminModel>> build() async {
    return _fetchRequests();
  }

  Future<List<WithdrawalRequestAdminModel>> _fetchRequests() async {
    final response = await Supabase.instance.client
        .from('withdrawal_requests')
        .select('*, provider:profiles!withdrawal_requests_provider_id_fkey(full_name)')
        .order('created_at', ascending: false);
        
    return (response as List).map((data) => WithdrawalRequestAdminModel.fromJson(data)).toList();
  }

  Future<void> fetchRequests() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRequests());
  }

  Future<bool> updateRequestStatus(String id, String status) async {
    try {
      String dbStatus;
      if (status == 'approved') {
        dbStatus = 'Approved';
      } else if (status == 'rejected') {
        dbStatus = 'Rejected';
      } else {
        return false;
      }
      
      await Supabase.instance.client.rpc('admin_handle_withdrawal', params: {
        'p_request_id': id,
        'p_status': dbStatus,
      });

      await fetchRequests();
      return true;
    } catch (e) {
      print('Error updating withdrawal request: $e');
      return false;
    }
  }
}
