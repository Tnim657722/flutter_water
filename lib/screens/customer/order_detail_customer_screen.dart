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

class OrderDetailCustomerScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailCustomerScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final order = provider.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => provider.orders.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order.orderNumber),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(status: order.status),
                  const SizedBox(height: 16),
                  Text(
                    order.statusLabel,
                    style: GoogleFonts.kanit(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '฿${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.kanit(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            // Delivery stepper
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('สถานะการจัดส่ง',
                      style: GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 16),
                  _DeliveryTimeline(status: order.status),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // Items
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('รายการสินค้า',
                      style: GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/product_water.png',
                            width: 44, height: 44, fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(item.productName,
                              style: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                        Text(
                          '${item.quantity} × ฿${item.pricePerUnit.toStringAsFixed(0)}',
                          style: GoogleFonts.kanit(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('รวมทั้งสิ้น',
                          style: GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text('฿${order.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.kanit(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // Delivery info
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ข้อมูลการจัดส่ง',
                      style: GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 14),
                  _Row(icon: Icons.location_on, label: 'ที่อยู่', value: order.deliveryAddress),
                  _Row(icon: Icons.calendar_today, label: 'วันที่ส่ง',
                      value: DateFormat('d MMMM y').format(order.deliveryDate)),
                  if (order.note != null)
                    _Row(icon: Icons.note, label: 'หมายเหตุ', value: order.note!),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),

            // Proof photo (if delivered)
            if (order.status == 'delivered' && order.proofPhotoUrl != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: AppColors.success.withValues(alpha: 0.08), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text('หลักฐานการส่ง',
                            style: GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 16,
                                color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: order.proofPhotoUrl!.startsWith('local://')
                          ? Image.file(
                              File(order.proofPhotoUrl!.replaceFirst('local://', '')),
                              width: double.infinity, height: 200, fit: BoxFit.cover,
                            )
                          : Container(
                              width: double.infinity, height: 150,
                              color: AppColors.success.withValues(alpha: 0.1),
                              child: const Icon(Icons.check_circle, color: AppColors.success, size: 60),
                            ),
                    ),
                    if (order.deliveredAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'ส่งสำเร็จเมื่อ: ${DateFormat('d MMM y HH:mm').format(order.deliveredAt!)}',
                        style: GoogleFonts.kanit(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.kanit(fontSize: 11, color: AppColors.textSecondary)),
                Text(value,
                    style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryTimeline extends StatelessWidget {
  final String status;
  const _DeliveryTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('รอดำเนินการ', Icons.schedule, 'pending'),
      ('มอบหมายงาน', Icons.assignment_turned_in, 'assigned'),
      ('กำลังจัดส่ง', Icons.local_shipping, 'delivering'),
      ('ส่งสำเร็จ', Icons.check_circle, 'delivered'),
    ];

    int currentIdx = 0;
    switch (status) {
      case 'pending': currentIdx = 0; break;
      case 'assigned': currentIdx = 1; break;
      case 'delivering': currentIdx = 2; break;
      case 'delivered': currentIdx = 3; break;
    }

    return Column(
      children: steps.asMap().entries.map((e) {
        final idx = e.key;
        final step = e.value;
        final isDone = idx <= currentIdx;
        final isCurrent = idx == currentIdx;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.primary : Colors.grey.shade100,
                    border: isCurrent ? Border.all(color: AppColors.accent, width: 3) : null,
                    boxShadow: isDone ? [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)
                    ] : null,
                  ),
                  child: Icon(step.$2, size: 18,
                      color: isDone ? Colors.white : Colors.grey.shade400),
                ),
                if (idx < steps.length - 1)
                  Container(
                    width: 2,
                    height: 30,
                    color: idx < currentIdx ? AppColors.primary : Colors.grey.shade200,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                step.$1,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
