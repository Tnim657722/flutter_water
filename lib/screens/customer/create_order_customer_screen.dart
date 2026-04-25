import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/order_model.dart';

class CreateOrderCustomerScreen extends StatefulWidget {
  const CreateOrderCustomerScreen({super.key});

  @override
  State<CreateOrderCustomerScreen> createState() => _CreateOrderCustomerScreenState();
}

class _CreateOrderCustomerScreenState extends State<CreateOrderCustomerScreen> {
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 1));
  final _noteCtrl = TextEditingController();
  final Map<String, int> _quantities = {};

  double get _total {
    double sum = 0;
    final provider = context.read<AppProvider>();
    for (final p in provider.products) {
      final qty = _quantities[p.id] ?? 0;
      sum += qty * p.pricePerUnit;
    }
    return sum;
  }

  bool get _canSubmit => _quantities.values.any((v) => v > 0);

  void _submit() {
    if (!_canSubmit) return;
    final provider = context.read<AppProvider>();
    final currentUser = provider.currentUser;
    if (currentUser == null) return;

    final uuid = const Uuid();
    final orderNumber = 'AQ-${DateTime.now().year}-${(provider.orders.length + 1).toString().padLeft(3, '0')}';

    final items = provider.products
        .where((p) => (_quantities[p.id] ?? 0) > 0)
        .map((p) {
          final qty = _quantities[p.id]!;
          return OrderItem(
            id: uuid.v4(),
            orderId: '',
            productId: p.id,
            productName: p.name,
            quantity: qty,
            pricePerUnit: p.pricePerUnit,
            subtotal: qty * p.pricePerUnit,
          );
        })
        .toList();

    final order = OrderModel(
      id: uuid.v4(),
      orderNumber: orderNumber,
      customerId: currentUser.id,
      customerName: currentUser.fullName,
      status: 'pending',
      totalAmount: _total,
      deliveryAddress: currentUser.address,
      deliveryDate: _deliveryDate,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      items: items,
      createdAt: DateTime.now(),
    );

    provider.addOrder(order);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ส่งคำสั่งซื้อเรียบร้อยแล้ว!', style: GoogleFonts.kanit()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currentUser = provider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('สั่งน้ำดื่ม'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Delivery Address
          _SectionHeader(title: 'จัดส่งที่', icon: Icons.location_on),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 10),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentUser.fullName, style: GoogleFonts.kanit(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        currentUser.address,
                        style: GoogleFonts.kanit(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Delivery date
          _SectionHeader(title: 'วันที่ต้องการรับสินค้า', icon: Icons.calendar_today),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _deliveryDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => _deliveryDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Text(
                    '${_deliveryDate.day}/${_deliveryDate.month}/${_deliveryDate.year}',
                    style: GoogleFonts.kanit(fontSize: 15, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Products
          _SectionHeader(title: 'สินค้า', icon: Icons.local_drink),
          ...provider.products.map((p) {
            final qty = _quantities[p.id] ?? 0;
            final stock = provider.getStockForProduct(p.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: qty > 0 ? AppColors.accent : AppColors.border,
                  width: qty > 0 ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/product_water.png',
                      width: 50, height: 50, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('฿${p.pricePerUnit.toStringAsFixed(0)} / ${p.unit}',
                            style: GoogleFonts.kanit(fontSize: 12, color: AppColors.textSecondary)),
                        if (stock <= 0)
                          Text('สินค้าหมด', style: GoogleFonts.kanit(fontSize: 11, color: AppColors.danger)),
                      ],
                    ),
                  ),
                  // Quantity stepper
                  Row(
                    children: [
                      _QtyBtn(
                        icon: Icons.remove,
                        onTap: qty > 0
                            ? () => setState(() => _quantities[p.id] = qty - 1)
                            : null,
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: qty > 0 ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      _QtyBtn(
                        icon: Icons.add,
                        onTap: qty < stock
                            ? () => setState(() => _quantities[p.id] = qty + 1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Note
          _SectionHeader(title: 'หมายเหตุถึงพนักงานส่ง', icon: Icons.note_alt_outlined),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'เช่น วางไว้หน้าบ้าน, โทรหาก่อนถึง...',
              hintStyle: GoogleFonts.kanit(color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ยอดรวม', style: GoogleFonts.kanit(color: Colors.white70, fontSize: 14)),
                    Text(
                      '฿${_total.toStringAsFixed(0)}',
                      style: GoogleFonts.kanit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSubmit ? AppColors.accent : Colors.white24,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'ยืนยันสั่งซื้อ',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 18,
            color: onTap != null ? AppColors.primary : Colors.grey.shade400),
      ),
    );
  }
}
