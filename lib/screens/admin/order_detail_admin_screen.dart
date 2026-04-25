import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/order_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/status_badge.dart';

class OrderDetailAdminScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailAdminScreen({super.key, required this.orderId});

  @override
  State<OrderDetailAdminScreen> createState() => _OrderDetailAdminScreenState();
}

class _OrderDetailAdminScreenState extends State<OrderDetailAdminScreen> {
  File? _proofImage;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) {
      setState(() => _proofImage = File(img.path));
    }
  }

  Future<void> _uploadAndMarkDelivered(OrderModel order) async {
    setState(() => _uploading = true);

    // Upload to Supabase Storage
    final url = await SupabaseService.uploadDeliveryProof(order.id, _proofImage!);

    if (!mounted) return;

    if (!mounted) return;
    await context.read<AppProvider>().updateOrderStatus(
      order.id,
      'delivered',
      proofPhotoUrl: url ?? 'local://${_proofImage!.path}',
    );

    if (!mounted) return;
    setState(() => _uploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ยืนยันส่งสำเร็จ! 🎉', style: GoogleFonts.kanit()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final order = provider.orders.firstWhere(
      (o) => o.id == widget.orderId,
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
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.orderNumber,
                        style: GoogleFonts.kanit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ยอดรวม: ฿${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'สร้างเมื่อ ${DateFormat('d MMM y HH:mm').format(order.createdAt)}',
                    style: GoogleFonts.kanit(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 20),

            // Customer info
            _InfoCard(
              title: 'ข้อมูลลูกค้า',
              icon: Icons.person,
              children: [
                _InfoRow(label: 'ชื่อ', value: order.customerName),
                _InfoRow(label: 'ที่อยู่', value: order.deliveryAddress),
                _InfoRow(
                  label: 'วันที่ส่ง',
                  value: DateFormat('d MMMM y').format(order.deliveryDate),
                ),
                if (order.note != null)
                  _InfoRow(label: 'หมายเหตุ', value: order.note!),
              ],
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // Items
            _InfoCard(
              title: 'รายการสินค้า',
              icon: Icons.inventory_2_outlined,
              children: [
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset('assets/images/product_water.png', fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName,
                                style: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 14)),
                            Text('${item.quantity} × ฿${item.pricePerUnit.toStringAsFixed(0)}',
                                style: GoogleFonts.kanit(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        '฿${item.subtotal.toStringAsFixed(0)}',
                        style: GoogleFonts.kanit(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
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
                    Text(
                      '฿${order.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.kanit(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // Update status
            if (order.status != 'delivered' && order.status != 'cancelled') ...[
              _InfoCard(
                title: 'อัปเดตสถานะ',
                icon: Icons.update,
                children: [
                  // Status stepper
                  _StatusStepper(currentStatus: order.status),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (order.status == 'pending')
                        _ActionBtn(
                          label: 'มอบหมายงาน',
                          color: AppColors.primary,
                          icon: Icons.assignment_turned_in,
                          onTap: () => context.read<AppProvider>()
                              .updateOrderStatus(order.id, 'assigned'),
                        ),
                      if (order.status == 'assigned')
                        _ActionBtn(
                          label: 'เริ่มส่งของ',
                          color: AppColors.accent,
                          icon: Icons.local_shipping,
                          onTap: () => context.read<AppProvider>()
                              .updateOrderStatus(order.id, 'delivering'),
                        ),
                      if (order.status != 'delivered')
                        _ActionBtn(
                          label: 'ยกเลิก',
                          color: AppColors.danger,
                          icon: Icons.cancel_outlined,
                          onTap: () => context.read<AppProvider>()
                              .updateOrderStatus(order.id, 'cancelled'),
                        ),
                    ],
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),
            ],

            // Proof photo upload (for delivering status)
            if (order.status == 'delivering') ...[
              _InfoCard(
                title: 'อัปโหลดรูปยืนยันส่งของ',
                icon: Icons.camera_alt,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _proofImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(_proofImage!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate_outlined,
                                    color: AppColors.accent, size: 48),
                                const SizedBox(height: 8),
                                Text('แตะเพื่อเลือกรูปภาพ',
                                    style: GoogleFonts.kanit(color: AppColors.accent, fontSize: 14)),
                              ],
                            ),
                    ),
                  ),
                  if (_proofImage != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _uploading ? null : () => _uploadAndMarkDelivered(order),
                        icon: _uploading
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(
                          _uploading ? 'กำลังอัปโหลด...' : 'ยืนยันส่งสำเร็จ',
                          style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ],
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 16),
            ],

            // Delivered proof
            if (order.status == 'delivered' && order.proofPhotoUrl != null) ...[
              _InfoCard(
                title: 'รูปยืนยันการส่ง',
                icon: Icons.verified,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: order.proofPhotoUrl!.startsWith('local://')
                        ? Image.file(
                            File(order.proofPhotoUrl!.replaceFirst('local://', '')),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: double.infinity,
                            height: 200,
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
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.kanit(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.kanit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  final String currentStatus;
  const _StatusStepper({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('รอดำเนินการ', 'pending'),
      ('มอบหมาย', 'assigned'),
      ('กำลังส่ง', 'delivering'),
      ('ส่งสำเร็จ', 'delivered'),
    ];

    final dummy = OrderModel(
      id: '', orderNumber: '', customerId: '', customerName: '',
      status: currentStatus, totalAmount: 0, deliveryAddress: '',
      deliveryDate: DateTime.now(), items: const [], createdAt: DateTime.now(),
    );
    final currentIdx = dummy.statusIndex;

    return Row(
      children: steps.asMap().entries.map((e) {
        final idx = e.key;
        final step = e.value;
        final isDone = idx <= currentIdx;
        final isCurrent = idx == currentIdx;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.primary : Colors.grey.shade200,
                        border: isCurrent
                            ? Border.all(color: AppColors.accent, width: 2)
                            : null,
                      ),
                      child: Icon(
                        isDone ? Icons.check : Icons.circle_outlined,
                        size: 14,
                        color: isDone ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.$1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kanit(
                        fontSize: 9,
                        color: isDone ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (idx < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: idx < currentIdx ? AppColors.primary : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: GoogleFonts.kanit(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
