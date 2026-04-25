import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/status_badge.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final orders = provider.getOrdersForCustomer(user.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ออเดอร์ของฉัน'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('ยังไม่มีออเดอร์',
                      style: GoogleFonts.kanit(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (ctx, i) {
                final order = orders[i];
                return GestureDetector(
                  onTap: () => context.push('/customer/orders/${order.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.orderNumber,
                                style: GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                            StatusBadge(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '• ${item.productName} × ${item.quantity}',
                            style: GoogleFonts.kanit(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        )),
                        const SizedBox(height: 8),
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
                  ).animate().fadeIn(delay: (i * 60).ms),
                );
              },
            ),
    );
  }
}
