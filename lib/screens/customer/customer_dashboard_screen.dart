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

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final myOrders = provider.getOrdersForCustomer(user.id);
    final activeOrders = myOrders.where((o) => o.status != 'delivered' && o.status != 'cancelled').toList();
    final latestOrder = myOrders.isNotEmpty ? myOrders.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.accentGradient),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
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
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.2),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset('assets/images/app_logo.png'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('AquaFlow',
                                        style: GoogleFonts.kanit(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                  onPressed: () {
                                    provider.logout();
                                    context.go('/login');
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'สวัสดี, ${user.fullName.split(' ').first} 🌊',
                              style: GoogleFonts.kanit(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'มีออเดอร์ที่กำลังดำเนินการ ${activeOrders.length} รายการ',
                              style: GoogleFonts.kanit(
                                color: Colors.white.withValues(alpha: 0.85),
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
                // Quick stats
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'ออเดอร์ทั้งหมด',
                        value: '${myOrders.length}',
                        icon: Icons.receipt_long,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'ส่งสำเร็จแล้ว',
                        value: '${myOrders.where((o) => o.status == 'delivered').length}',
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                // Latest order
                if (latestOrder != null) ...[
                  Text('ออเดอร์ล่าสุด',
                      style: GoogleFonts.kanit(
                          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary))
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),
                  _LatestOrderCard(order: latestOrder).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
                  const SizedBox(height: 24),
                ],

                // Active orders
                if (activeOrders.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('กำลังดำเนินการ',
                          style: GoogleFonts.kanit(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () => context.go('/customer/orders'),
                        child: Text('ดูทั้งหมด',
                            style: GoogleFonts.kanit(color: AppColors.accent)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),

                  ...activeOrders.take(3).toList().asMap().entries.map((e) =>
                    _SmallOrderCard(
                      order: e.value,
                      onTap: () => context.push('/customer/orders/${e.value.id}'),
                    ).animate().fadeIn(delay: (350 + e.key * 80).ms).slideX(begin: 0.1)
                  ),
                ],

                // Product promo
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/product_water.png'),
                      alignment: Alignment.centerRight,
                      fit: BoxFit.contain,
                      opacity: 0.15,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('น้ำดื่มคุณภาพ',
                                style: GoogleFonts.kanit(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                            Text('ส่งตรงถึงหน้าบ้าน\nทุกวันโดยไม่มีวันหยุด',
                                style: GoogleFonts.kanit(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => context.go('/customer/orders'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text('ดูออเดอร์ของฉัน',
                                  style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.kanit(
                      fontSize: 26, fontWeight: FontWeight.w700, color: color)),
              Text(label,
                  style: GoogleFonts.kanit(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LatestOrderCard extends StatelessWidget {
  final OrderModel order;
  const _LatestOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/customer/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNumber,
                    style: GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 16)),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.accent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(order.deliveryAddress,
                      style: GoogleFonts.kanit(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(DateFormat('d MMM y').format(order.deliveryDate),
                    style: GoogleFonts.kanit(fontSize: 12, color: AppColors.textSecondary)),
                const Spacer(),
                Text('฿${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.kanit(
                        fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  const _SmallOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.water_drop, color: AppColors.accent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(order.orderNumber,
                  style: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            StatusBadge(status: order.status),
          ],
        ),
      ),
    );
  }
}
