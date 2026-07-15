import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final settingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response = await Supabase.instance.client
      .from('app_settings')
      .select('value')
      .eq('key', 'commission_rates')
      .single();
  return response['value'] as Map<String, dynamic>;
});

class SettingsNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> updateCommissionRates(double defaultRate, double premiumRate) async {
    state = true;
    try {
      await Supabase.instance.client.from('app_settings').update({
        'value': {
          'default_rate': defaultRate,
          'premium_rate': premiumRate,
        }
      }).eq('key', 'commission_rates');
    } catch (e) {
      state = false;
      rethrow;
    }
    state = false;
  }
}

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, bool>(() => SettingsNotifier());
