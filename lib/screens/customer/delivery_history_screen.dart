import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/status_badge.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  String _selectedMonth = 'ทั้งหมด';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final allOrders = provider.getOrdersForCustomer(user.id);

    final months = ['ทั้งหมด', ...{
      ...allOrders.map((o) => DateFormat('MMMM y').format(o.createdAt))
    }];

    final filtered = _selectedMonth == 'ทั้งหมด'
        ? allOrders
        : allOrders.where((o) =>
            DateFormat('MMMM y').format(o.createdAt) == _selectedMonth).toList();

    final delivered = filtered.where((o) => o.status == 'delivered').toList();
    final totalSpent = delivered.fold<double>(0, (s, o) => s + o.totalAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ประวัติการสั่งซื้อ'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    label: 'ออเดอร์ทั้งหมด',
                    value: '${filtered.length}',
                    icon: Icons.receipt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryChip(
                    label: 'ยอดรวม',
                    value: '฿${totalSpent.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),
          ),

          // Month filter
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: months.length,
              itemBuilder: (ctx, i) {
                final m = months[i];
                final isSelected = m == _selectedMonth;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMonth = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      m,
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Orders
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        Text('ไม่มีประวัติ',
                            style: GoogleFonts.kanit(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final order = filtered[i];
                      return GestureDetector(
                        onTap: () => context.push('/customer/orders/${order.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.05),
                                  blurRadius: 10),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Proof thumb
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: order.status == 'delivered'
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : AppColors.accent.withValues(alpha: 0.1),
                                ),
                                child: order.proofPhotoUrl != null &&
                                        order.proofPhotoUrl!.startsWith('local://')
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(order.proofPhotoUrl!.replaceFirst('local://', '')),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        order.status == 'delivered'
                                            ? Icons.check_circle
                                            : Icons.water_drop,
                                        color: order.status == 'delivered'
                                            ? AppColors.success
                                            : AppColors.accent,
                                        size: 28,
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(order.orderNumber,
                                        style: GoogleFonts.kanit(
                                            fontWeight: FontWeight.w700, fontSize: 14)),
                                    Text(
                                      '${order.items.length} รายการ • ${DateFormat('d MMM y').format(order.createdAt)}',
                                      style: GoogleFonts.kanit(
                                          fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 4),
                                    StatusBadge(status: order.status),
                                  ],
                                ),
                              ),
                              Text('฿${order.totalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.kanit(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ).animate().fadeIn(delay: (i * 60).ms),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentLight, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.kanit(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              Text(label,
                  style: GoogleFonts.kanit(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
