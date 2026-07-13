import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text('ملف مزود الخدمة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // extra padding for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Profile Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surface, width: 4),
                              image: const DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 2),
                              ),
                              child: const Icon(Icons.verified, color: AppColors.onSecondary, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أحمد عبدالله',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.plumbing, size: 16, color: AppColors.onSecondaryContainer),
                                  const SizedBox(width: 4),
                                  Text(
                                    'أخصائي سباكة',
                                    style: TextStyle(color: AppColors.onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Rating and Location
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                const Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('(128 تقييم)', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                                const SizedBox(width: 8),
                                const Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                                const SizedBox(width: 8),
                                const Icon(Icons.location_on, color: AppColors.outline, size: 16),
                                const SizedBox(width: 2),
                                Text('الرياض، السعودية', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Section
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, Icons.task_alt, AppColors.primary, '450+', 'مهمة منجزة')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, Icons.workspace_premium, AppColors.secondary, '8', 'سنوات خبرة')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, Icons.timer, AppColors.tertiary, 'ساعة', 'متوسط الرد')),
                  ],
                ),
                const SizedBox(height: 32),

                // About Section
                Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'نبذة عني',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'متخصص في كافة أعمال السباكة المنزلية والتجارية بخبرة تتجاوز 8 سنوات في مدينة الرياض. أقدم خدمات تأسيس شبكات المياه والصرف الصحي، الكشف عن التسربات بأحدث الأجهزة الإلكترونية دون تكسير، وصيانة وتركيب الأدوات الصحية بضمان الجودة والالتزام بالمواعيد.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                  ),
                ),
                const SizedBox(height: 32),

                // Services Offered
                Row(
                  children: [
                    const Icon(Icons.handyman, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'الخدمات والأسعار',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildServiceCard(
                  context,
                  title: 'كشف تسربات المياه',
                  subtitle: 'فحص شامل بأجهزة إلكترونية',
                  price: '150 ر.س',
                  icon: Icons.water_drop,
                ),
                const SizedBox(height: 12),
                _buildServiceCard(
                  context,
                  title: 'تركيب أدوات صحية',
                  subtitle: 'مغاسل، مراحيض، خلاطات',
                  price: '80 ر.س',
                  icon: Icons.bathtub,
                ),
                const SizedBox(height: 32),

                // Portfolio
                Row(
                  children: [
                    const Icon(Icons.photo_library, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'أعمال سابقة',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildPortfolioImage('https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=300&auto=format&fit=crop'),
                    _buildPortfolioImage('https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?q=80&w=300&auto=format&fit=crop'),
                  ],
                ),
              ],
            ),
          ),
          
          // Fixed Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/booking');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.calendar_month, size: 20),
                          SizedBox(width: 8),
                          Text('احجز موعداً الآن'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      context.push('/live_chat');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      minimumSize: const Size(56, 56),
                      backgroundColor: AppColors.surfaceContainer,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.chat, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {required String title, required String subtitle, required String price, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('يبدأ من', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline)),
              Text(price, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    );
  }
}
