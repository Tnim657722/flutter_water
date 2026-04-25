import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/splash_bg.png',
            fit: BoxFit.cover,
          ),
          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.navyDark.withValues(alpha: 0.3),
                  AppColors.navyDark.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          // Ripple rings
          Center(
            child: AnimatedBuilder(
              animation: _rippleController,
              builder: (ctx, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (i) {
                    final delay = i / 3;
                    final progress = (_rippleController.value + delay) % 1.0;
                    return Opacity(
                      opacity: (1 - progress) * 0.4,
                      child: Container(
                        width: 80 + progress * 200,
                        height: 80 + progress * 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.6),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                // Title
                Text(
                  'AquaFlow',
                  style: GoogleFonts.kanit(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, delay: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'ระบบจัดการส่งน้ำดื่ม',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.accentLight,
                    letterSpacing: 1,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms),
                const SizedBox(height: 80),
                // Loading indicator
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1000.ms),
              ],
            ),
          ),
          // Version
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0 • AquaFlow Delivery System',
              textAlign: TextAlign.center,
              style: GoogleFonts.kanit(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ).animate().fadeIn(delay: 1200.ms),
          ),
        ],
      ),
    );
  }
}
