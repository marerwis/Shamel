import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/categories_provider.dart';
import '../../../core/theme/app_colors.dart';

class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(rootCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع التصنيفات'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('لا توجد تصنيفات حالياً'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    context.push('/category_details', extra: cat);
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      cat.icon != null && cat.icon!.isNotEmpty
                          ? Image.network(cat.icon!, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                          : const Center(child: Icon(Icons.category, color: AppColors.primary, size: 50)),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 8,
                        right: 8,
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
