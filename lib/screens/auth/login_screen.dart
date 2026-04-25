import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    await Future.delayed(const Duration(milliseconds: 800)); // simulate API

    if (!mounted) return;
    final provider = context.read<AppProvider>();
    final success = await provider.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final user = provider.currentUser!;
      if (user.isAdmin) {
        context.go('/admin');
      } else {
        context.go('/customer');
      }
    } else {
      final errorDetail = provider.error ?? 'ไม่พบผู้ใช้ในระบบ Supabase (Query returned null)';
      setState(() => _errorMsg = errorDetail);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Debug: $errorDetail')));
    }
  }

  void _fillDemo(String username, String password) {
    _usernameCtrl.text = username;
    _passwordCtrl.text = password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          ),
          // Wave pattern
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.fitWidth,
              opacity: const AlwaysStoppedAnimation(0.15),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
                    ),
                  ).animate().fadeIn().scale(curve: Curves.elasticOut, duration: 700.ms),
                  const SizedBox(height: 20),
                  Text(
                    'AquaFlow',
                    style: GoogleFonts.kanit(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  Text(
                    'เข้าสู่ระบบ',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      color: AppColors.accentLight,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 50),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ยินดีต้อนรับ 👋',
                          style: GoogleFonts.kanit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'กรุณาเข้าสู่ระบบเพื่อดำเนินการต่อ',
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Username
                        TextField(
                          controller: _usernameCtrl,
                          decoration: InputDecoration(
                            labelText: 'ชื่อผู้ใช้',
                            hintText: 'กรอกชื่อผู้ใช้',
                            prefixIcon: const Icon(Icons.person_outline, color: AppColors.accent),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        // Password
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่าน',
                            hintText: 'กรอกรหัสผ่าน',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.accent),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          onSubmitted: (_) => _login(),
                        ),
                        if (_errorMsg != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _errorMsg!,
                                  style: GoogleFonts.kanit(
                                    color: AppColors.danger,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Login button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'เข้าสู่ระบบ',
                                    style: GoogleFonts.kanit(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),
                  // Demo accounts
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🔑 บัญชีทดสอบ',
                          style: GoogleFonts.kanit(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DemoButton(
                                label: '👨‍💼 Admin',
                                sub: 'admin / admin',
                                onTap: () => _fillDemo('admin', 'admin'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DemoButton(
                                label: '👤 ลูกค้า',
                                sub: 'somchai / 1234',
                                onTap: () => _fillDemo('somchai', '1234'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _DemoButton({required this.label, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 2),
            Text(sub, style: GoogleFonts.kanit(color: AppColors.accentLight, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
