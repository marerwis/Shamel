import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../models/category_model.dart';
import '../../home/providers/services_provider.dart';

class ServicesScreen extends ConsumerWidget {
  final CategoryModel category;

  const ServicesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We fetch all services and filter by category name
    // Because services table has 'category' as text matching the category name
    final servicesAsync = ref.watch(appServicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text('خدمات ${category.name}'),
        centerTitle: true,
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
        data: (allServices) {
          final services = allServices.where((s) => s.category == category.name).toList();

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.miscellaneous_services, size: 64, color: AppColors.outline),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد خدمات محددة في هذا التصنيف',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/create_request');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('قدم طلب خدمة عام'),
                  )
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.home_repair_service, color: AppColors.onPrimaryContainer),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'يبدأ من: ${service.basePrice} د.ل',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        service.description ?? 'لا يوجد وصف متاح لهذه الخدمة.',
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/booking', extra: {'service': service});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('طلب الخدمة', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
