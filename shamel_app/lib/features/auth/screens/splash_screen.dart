import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Pattern (Dots)
          CustomPaint(
            painter: _DottedBackgroundPainter(),
          ),
          
          // Ambient Glow Elements
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withOpacity(0.5),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds),
          ),
          Positioned(
            bottom: -150,
            left: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E3A8A).withOpacity(0.4),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 3.seconds),
          ),

          // Central Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryContainer.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.apps,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack)
                 .then().shimmer(duration: 1.seconds, color: AppColors.secondaryContainer.withOpacity(0.2)),
                
                const SizedBox(height: 32),
                
                // Brand Name
                Text(
                  'شامل',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.onPrimary,
                        letterSpacing: -1,
                      ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'كل احتياجاتك في تطبيق واحد',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryFixedDim.withOpacity(0.9),
                      ),
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 64),
                
                // Loading Indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),

          // Footer
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v1.0.0',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primaryFixedDim.withOpacity(0.5),
                    ),
              ).animate().fadeIn(delay: 1.seconds),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const double spacing = 40.0;
    const double radius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
