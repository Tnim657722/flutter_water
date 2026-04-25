import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/product_model.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  void _showAddStockDialog(BuildContext context, ProductModel product) {
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final provider = context.read<AppProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'รับสต็อก: ${product.name}',
                style: GoogleFonts.kanit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'สต็อกปัจจุบัน: ${provider.getStockForProduct(product.id)} ${product.unit}',
                style: GoogleFonts.kanit(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'จำนวนที่รับเข้า',
                  prefixIcon: Icon(Icons.add_box_outlined, color: AppColors.success),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'หมายเหตุ (เช่น รับจากโรงงาน ABC)',
                  prefixIcon: Icon(Icons.note_outlined, color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final qty = int.tryParse(qtyCtrl.text);
                    if (qty != null && qty > 0) {
                      provider.addStock(product.id, qty, noteCtrl.text.trim());
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('เพิ่มสต็อก ${product.name} $qty ${product.unit} สำเร็จ',
                            style: GoogleFonts.kanit()),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text('รับสต็อก', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('จัดการสต็อก'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(context, provider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.warehouse, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สต็อกรวมทั้งหมด',
                      style: GoogleFonts.kanit(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '${provider.getTotalStock()} หน่วย',
                      style: GoogleFonts.kanit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 24),
          Text(
            'สินค้าทั้งหมด',
            style: GoogleFonts.kanit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ...provider.products.asMap().entries.map((e) {
            final product = e.value;
            final stock = provider.getStockForProduct(product.id);
            final maxStock = 300;
            final ratio = (stock / maxStock).clamp(0.0, 1.0);
            final stockColor = ratio < 0.2
                ? AppColors.danger
                : ratio < 0.5
                    ? AppColors.warning
                    : AppColors.success;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/product_water.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.kanit(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              product.unit,
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$stock',
                            style: GoogleFonts.kanit(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: stockColor,
                            ),
                          ),
                          Text(
                            'คงเหลือ',
                            style: GoogleFonts.kanit(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '฿${product.pricePerUnit.toStringAsFixed(0)} / ${product.unit}',
                        style: GoogleFonts.kanit(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddStockDialog(context, product),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text('รับเข้า', style: GoogleFonts.kanit(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (100 + e.key * 80).ms).slideY(begin: 0.2);
          }),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'ประวัติสต็อก',
                  style: GoogleFonts.kanit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.stockTransactions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final tx = provider.stockTransactions[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: tx.isIn
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          tx.isIn ? Icons.add_circle_outline : Icons.remove_circle_outline,
                          color: tx.isIn ? AppColors.success : AppColors.danger,
                        ),
                      ),
                      title: Text(
                        tx.productName,
                        style: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        tx.note ?? '',
                        style: GoogleFonts.kanit(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${tx.isIn ? '+' : '-'}${tx.quantity}',
                            style: GoogleFonts.kanit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: tx.isIn ? AppColors.success : AppColors.danger,
                            ),
                          ),
                          Text(
                            '${tx.createdAt.day}/${tx.createdAt.month}',
                            style: GoogleFonts.kanit(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
