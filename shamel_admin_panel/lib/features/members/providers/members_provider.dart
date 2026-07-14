import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberModel {
  final String id;
  final String? fullName;
  final String role;
  final String status;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  MemberModel({
    required this.id,
    this.fullName,
    required this.role,
    required this.status,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      fullName: json['full_name'],
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

final membersProvider = AsyncNotifierProvider<MembersNotifier, List<MemberModel>>(() {
  return MembersNotifier();
});

class MembersNotifier extends AsyncNotifier<List<MemberModel>> {
  @override
  FutureOr<List<MemberModel>> build() async {
    return _fetchMembers();
  }

  final _supabase = Supabase.instance.client;

  Future<List<MemberModel>> _fetchMembers() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
        
    return (response as List).map((data) => MemberModel.fromJson(data)).toList();
  }

  Future<void> fetchMembers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMembers());
  }

  Future<bool> updateMemberStatus(String id, String status) async {
    try {
      await _supabase.from('profiles').update({'status': status}).eq('id', id);
      await fetchMembers();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// 2. Customers Provider
final customersProvider = Provider<AsyncValue<List<MemberModel>>>((ref) {
  final allMembers = ref.watch(membersProvider);
  return allMembers.whenData((members) => members.where((m) => m.role == 'user').toList());
});

// 3. Providers Provider
final providersListProvider = Provider<AsyncValue<List<MemberModel>>>((ref) {
  final allMembers = ref.watch(membersProvider);
  return allMembers.whenData((members) => members.where((m) => m.role == 'provider').toList());
});
