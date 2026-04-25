import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/status_badge.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.2),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset('assets/images/app_logo.png'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'AquaFlow',
                                      style: GoogleFonts.kanit(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    provider.logout();
                                    context.go('/login');
                                  },
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'สวัสดี, ${provider.currentUser?.fullName ?? "Admin"} 👋',
                              style: GoogleFonts.kanit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE d MMMM y', 'th').format(DateTime.now()),
                              style: GoogleFonts.kanit(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.inventory_2,
                        label: 'สต็อกรวม',
                        value: '${provider.getTotalStock()}',
                        unit: 'หน่วย',
                        color: AppColors.primary,
                        gradient: AppColors.primaryGradient,
                        onTap: () => context.go('/admin/stock'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.pending_actions,
                        label: 'รอดำเนินการ',
                        value: '${provider.pendingOrdersCount}',
                        unit: 'ออเดอร์',
                        color: AppColors.warning,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
                        ),
                        onTap: () => context.go('/admin/orders'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_shipping,
                        label: 'กำลังส่ง',
                        value: '${provider.deliveringCount}',
                        unit: 'เส้นทาง',
                        color: AppColors.accent,
                        gradient: AppColors.accentGradient,
                        onTap: () => context.go('/admin/orders'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        label: 'ส่งสำเร็จวันนี้',
                        value: '${provider.deliveredTodayCount}',
                        unit: 'ออเดอร์',
                        color: AppColors.success,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF06D6A0), Color(0xFF05A87E)],
                        ),
                        onTap: () => context.go('/admin/orders'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 28),

                // Quick Actions
                Text(
                  'เมนูด่วน',
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuickAction(
                      icon: Icons.add_box_rounded,
                      label: 'รับสต็อก',
                      color: AppColors.primary,
                      onTap: () => context.go('/admin/stock'),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.note_add_rounded,
                      label: 'สร้างออเดอร์',
                      color: AppColors.accent,
                      onTap: () => context.push('/admin/orders/create'),
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.person_add_rounded,
                      label: 'เพิ่มลูกค้า',
                      color: AppColors.success,
                      onTap: () => context.go('/admin/customers'),
                    ),
                  ],
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),

                const SizedBox(height: 28),

                // Recent Orders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ออเดอร์ล่าสุด',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/admin/orders'),
                      child: Text('ดูทั้งหมด', style: GoogleFonts.kanit(color: AppColors.accent)),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                ...provider.orders.take(4).toList().asMap().entries.map((e) {
                  return _OrderCard(
                    order: e.value,
                    onTap: () => context.push('/admin/orders/${e.value.id}'),
                  ).animate().fadeIn(delay: (450 + e.key * 80).ms).slideX(begin: 0.1);
                }),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.kanit(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              unit,
              style: GoogleFonts.kanit(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.kanit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.kanit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.water_drop, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    order.customerName,
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: order.status),
                const SizedBox(height: 4),
                Text(
                  '฿${order.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
