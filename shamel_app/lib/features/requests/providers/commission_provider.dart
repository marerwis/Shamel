import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final commissionRateProvider = FutureProvider<double>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  // Get user profile to check if premium
  final profileRes = await supabase.from('profiles').select('is_premium').eq('id', userId).single();
  final isPremium = profileRes['is_premium'] == true;

  // Get commission rates
  final settingsRes = await supabase.from('app_settings').select('value').eq('key', 'commission_rates').single();
  final rates = settingsRes['value'] as Map<String, dynamic>;

  if (isPremium) {
    return (rates['premium_rate'] as num).toDouble();
  } else {
    return (rates['default_rate'] as num).toDouble();
  }
});
