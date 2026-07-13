import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: Row(
        children: [
          // Sidebar
          const AdminSidebar(),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Topbar
                const AdminTopbar(),
                // Page Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Current route to highlight the active menu item
    final String location = GoRouterState.of(context).uri.toString();

    return Container(
      width: 280,
      color: AppColors.inverseSurface, // Deep Royal Blue for admin sidebar
      child: Column(
        children: [
          // Logo Area
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                const Icon(Icons.shield, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  'شامل أدمن',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),
          
          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(context, 'نظرة عامة', Icons.dashboard, '/dashboard', location == '/dashboard'),
                _buildNavItem(context, 'إدارة الخدمات', Icons.home_repair_service, '/services', location == '/services'),
                _buildNavItem(context, 'إدارة الأعضاء', Icons.people, '/members', location == '/members'),
                _buildNavItem(context, 'إدارة الطلبات', Icons.receipt_long, '/orders', location == '/orders'),
                _buildNavItem(context, 'العروض الترويجية', Icons.local_offer, '/promotions', location == '/promotions'),
                _buildNavItem(context, 'النزاعات والشكاوى', Icons.gavel, '/disputes', location == '/disputes'),
                _buildNavItem(context, 'المعاملات المالية', Icons.account_balance_wallet, '/finance', location == '/finance'),
              ],
            ),
          ),
          
          // Bottom Area (Logout)
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white70)),
              onTap: () {
                context.go('/login');
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              hoverColor: Colors.white10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String path, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.secondaryFixed : Colors.white70),
        title: Text(
          title, 
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          )
        ),
        selected: isActive,
        selectedTileColor: AppColors.secondary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: Colors.white10,
        onTap: () {
          context.go(path);
        },
      ),
    );
  }
}

class AdminTopbar extends StatelessWidget {
  const AdminTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search
          SizedBox(
            width: 400,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث في النظام...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Profile & Actions
          Row(
            children: [
              IconButton(
                icon: const Badge(
                  label: Text('3'),
                  child: Icon(Icons.notifications_outlined),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 32, color: AppColors.outlineVariant),
              const SizedBox(width: 16),
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('أحمد علي', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Super Admin', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=100&auto=format&fit=crop'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
