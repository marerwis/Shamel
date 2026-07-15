import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisputeModel {
  final String id;
  final String orderId;
  final String raisedBy;
  final String reason;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;

  DisputeModel({
    required this.id,
    required this.orderId,
    required this.raisedBy,
    required this.reason,
    required this.status,
    this.adminNotes,
    required this.createdAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['id'],
      orderId: json['order_id'],
      raisedBy: json['raised_by'],
      reason: json['reason'],
      status: json['status'],
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

final disputesProvider = FutureProvider<List<DisputeModel>>((ref) async {
  final response = await Supabase.instance.client
      .from('disputes')
      .select()
      .order('created_at', ascending: false);
      
  return (response as List).map((data) => DisputeModel.fromJson(data)).toList();
});
