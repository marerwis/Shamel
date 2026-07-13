import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberModel {
  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String? phone;
  final String? avatarUrl;

  MemberModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    this.avatarUrl,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: json['role'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
    );
  }
}

// 1. All Members Provider
final allMembersProvider = FutureProvider<List<MemberModel>>((ref) async {
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .order('created_at', ascending: false);
      
  return (response as List).map((data) => MemberModel.fromJson(data)).toList();
});

// 2. Customers Provider
final customersProvider = Provider<AsyncValue<List<MemberModel>>>((ref) {
  final allMembers = ref.watch(allMembersProvider);
  return allMembers.whenData((members) => members.where((m) => m.role == 'customer').toList());
});

// 3. Providers Provider
final providersListProvider = Provider<AsyncValue<List<MemberModel>>>((ref) {
  final allMembers = ref.watch(allMembersProvider);
  return allMembers.whenData((members) => members.where((m) => m.role == 'provider').toList());
});
