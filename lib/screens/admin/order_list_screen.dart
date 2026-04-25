import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/status_badge.dart';
import 'package:intl/intl.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders, String status) {
    return orders
        .where((o) =>
            (status == 'all' || o.status == status) &&
            (o.customerName.contains(_search) ||
                o.orderNumber.contains(_search)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ออเดอร์ทั้งหมด'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.accent,
          labelStyle: GoogleFonts.kanit(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: const [
            Tab(text: 'ทั้งหมด'),
            Tab(text: 'รอส่ง'),
            Tab(text: 'กำลังส่ง'),
            Tab(text: 'สำเร็จ'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/orders/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('สร้างออเดอร์', style: GoogleFonts.kanit(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'ค้นหา ชื่อลูกค้า / เลขออเดอร์...',
                prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _search = ''),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderList(orders: _filterOrders(provider.orders, 'all')),
                _OrderList(orders: _filterOrders(provider.orders, 'pending') +
                    _filterOrders(provider.orders, 'assigned')),
                _OrderList(orders: _filterOrders(provider.orders, 'delivering')),
                _OrderList(orders: _filterOrders(provider.orders, 'delivered')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'ไม่มีออเดอร์',
              style: GoogleFonts.kanit(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final order = orders[i];
        return GestureDetector(
          onTap: () => context.push('/admin/orders/${order.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: GoogleFonts.kanit(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    StatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(order.customerName,
                        style: GoogleFonts.kanit(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: GoogleFonts.kanit(color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMM y').format(order.deliveryDate),
                          style: GoogleFonts.kanit(fontSize: 12, color: AppColors.accent),
                        ),
                      ],
                    ),
                    Text(
                      '฿${order.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.kanit(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: (i * 60).ms),
        );
      },
    );
  }
}
