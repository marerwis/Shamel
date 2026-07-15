import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamel_admin_panel/core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _defaultRateController = TextEditingController();
  final _premiumRateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final isSaving = ref.watch(settingsNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات النظام والعمولات',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 32),
        
        Expanded(
          child: settingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('خطأ: $err')),
            data: (rates) {
              if (_defaultRateController.text.isEmpty) {
                // Initialize controllers with percentage (e.g. 0.10 -> 10)
                _defaultRateController.text = ((rates['default_rate'] as num) * 100).toString();
                _premiumRateController.text = ((rates['premium_rate'] as num) * 100).toString();
              }

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('قم بتحديد نسبة الاستقطاع (العمولة) التي سيأخذها التطبيق من المزودين.', 
                      style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 400,
                      child: TextField(
                        controller: _defaultRateController,
                        decoration: const InputDecoration(
                          labelText: 'نسبة العمولة العادية (%)',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 400,
                      child: TextField(
                        controller: _premiumRateController,
                        decoration: const InputDecoration(
                          labelText: 'نسبة عمولة المزودين المميزين (%)',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isSaving ? null : () async {
                          final defaultRate = double.tryParse(_defaultRateController.text) ?? 10;
                          final premiumRate = double.tryParse(_premiumRateController.text) ?? 5;
                          
                          try {
                            await ref.read(settingsNotifierProvider.notifier).updateCommissionRates(
                              defaultRate / 100.0, 
                              premiumRate / 100.0
                            );
                            ref.invalidate(settingsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات بنجاح!')));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                            }
                          }
                        },
                        child: isSaving 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text('حفظ التغييرات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
