import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/user_model.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
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
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('เพิ่มลูกค้าใหม่',
                  style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'ชื่อ-นามสกุล',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.accent))),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'เบอร์โทร',
                      prefixIcon: Icon(Icons.phone_outlined, color: AppColors.accent))),
              const SizedBox(height: 10),
              TextField(controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'ที่อยู่จัดส่ง',
                      prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.accent))),
              const SizedBox(height: 10),
              TextField(controller: userCtrl,
                  decoration: const InputDecoration(labelText: 'Username',
                      prefixIcon: Icon(Icons.manage_accounts_outlined, color: AppColors.accent))),
              const SizedBox(height: 10),
              TextField(controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.accent))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && userCtrl.text.isNotEmpty) {
                      provider.addCustomer(UserModel(
                        id: const Uuid().v4(),
                        username: userCtrl.text.trim(),
                        password: passCtrl.text.trim().isEmpty ? '1234' : passCtrl.text.trim(),
                        role: 'customer',
                        fullName: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        address: addrCtrl.text.trim(),
                      ));
                      Navigator.pop(ctx);
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: Text('เพิ่มลูกค้า',
                      style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.w600)),
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
        title: const Text('จัดการลูกค้า'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text('เพิ่มลูกค้า', style: GoogleFonts.kanit(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.customers.length,
        itemBuilder: (ctx, i) {
          final c = provider.customers[i];
          final orderCount = provider.orders.where((o) => o.customerId == c.id).length;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      c.fullName[0],
                      style: GoogleFonts.kanit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.fullName,
                          style: GoogleFonts.kanit(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(c.phone,
                          style: GoogleFonts.kanit(fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        c.address,
                        style: GoogleFonts.kanit(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text('$orderCount',
                          style: GoogleFonts.kanit(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.primary)),
                      Text('ออเดอร์',
                          style: GoogleFonts.kanit(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (i * 60).ms);
        },
      ),
    );
  }
}
