import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

class WalletTransaction {
  final String id;
  final String userId;
  final num amount;
  final String type; // 'credit' or 'debit'
  final String description;
  final String? orderId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    this.orderId,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'],
      type: json['transaction_type'],
      description: json['description'],
      orderId: json['order_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class WithdrawalRequest {
  final String id;
  final String providerId;
  final num amount;
  final String status;
  final String bankName;
  final String iban;
  final DateTime createdAt;
  final DateTime? processedAt;

  WithdrawalRequest({
    required this.id,
    required this.providerId,
    required this.amount,
    required this.status,
    required this.bankName,
    required this.iban,
    required this.createdAt,
    this.processedAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'],
      providerId: json['provider_id'],
      amount: json['amount'],
      status: json['status'],
      bankName: json['bank_name'],
      iban: json['iban'],
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at']) : null,
    );
  }
}

class WalletState {
  final num balance;
  final List<WalletTransaction> transactions;

  WalletState({required this.balance, required this.transactions});
}

final walletProvider = AsyncNotifierProvider<WalletNotifier, WalletState>(() {
  return WalletNotifier();
});

class WalletNotifier extends AsyncNotifier<WalletState> {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  FutureOr<WalletState> build() async {
    return _fetchWallet();
  }

  Future<WalletState> _fetchWallet() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      return WalletState(balance: 0, transactions: []);
    }

    final balanceResponse = await _client.from('wallets').select('balance').eq('user_id', user.id).maybeSingle();
    final balance = balanceResponse != null ? (balanceResponse['balance'] ?? 0) : 0;

    final txResponse = await _client
        .from('wallet_transactions')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final transactions = (txResponse as List).map((data) => WalletTransaction.fromJson(data)).toList();

    return WalletState(balance: balance, transactions: transactions);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchWallet());
  }

  Future<bool> requestWithdrawal(num amount, String bankName, String iban) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    if (state.value == null || state.value!.balance < amount) {
      return false; // Insufficient balance
    }

    try {
      await _client.from('withdrawal_requests').insert({
        'provider_id': user.id,
        'amount': amount,
        'bank_name': bankName,
        'iban': iban,
      });

      // Also debit the wallet balance locally for optimistic UI
      // In production, we'd wait for DB trigger or handle server-side
      await refresh();
      return true;
    } on PostgrestException catch (e) {
      throw Exception('خطأ في قاعدة البيانات: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }
}
