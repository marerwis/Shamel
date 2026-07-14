import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/providers_provider.dart';

class ProvidersListScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  final String categoryName;

  const ProvidersListScreen({
    super.key,
    this.categoryId,
    this.categoryName = 'مزودي الخدمة',
  });

  @override
  ConsumerState<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends ConsumerState<ProvidersListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final asyncProviders = ref.watch(providersListProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن مزود خدمة...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: asyncProviders.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
              data: (providers) {
                final filteredProviders = providers.where((p) {
                  final name = '${p['first_name']} ${p['last_name']}'.toLowerCase();
                  final title = p['provider_details'][0]['title']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchQuery) || title.contains(_searchQuery);
                }).toList();

                if (filteredProviders.isEmpty) {
                  return const Center(child: Text('لا يوجد مزودي خدمة متاحين.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProviders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final provider = filteredProviders[index];
                    final providerDetails = provider['provider_details'][0];
                    return _buildProviderCard(context, provider, providerDetails);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, Map<String, dynamic> provider, Map<String, dynamic> details) {
    final avatarUrl = provider['avatar_url'];
    final name = '${provider['first_name']} ${provider['last_name']}';
    final title = details['title'] ?? 'مزود خدمة';
    final rating = details['rating']?.toString() ?? '5.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to provider profile / booking
              context.push('/booking');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('طلب'),
          ),
        ],
      ),
    );
  }
}
