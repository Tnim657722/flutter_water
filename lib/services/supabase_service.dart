import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/stock_model.dart';
import '../models/order_model.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // ==================== AUTH ====================
  static Future<UserModel?> login(String username, String password) async {
    final res = await _client
        .from('users')
        .select()
        .eq('username', username)
        .eq('password', password)
        .maybeSingle();

    if (res == null) return null;
    return UserModel.fromJson(res);
  }

  // ==================== USERS ====================
  static Future<List<UserModel>> getCustomers() async {
    final res = await _client
        .from('users')
        .select()
        .eq('role', 'customer')
        .order('created_at', ascending: false);
    return (res as List).map((e) => UserModel.fromJson(e)).toList();
  }

  static Future<UserModel> addCustomer(UserModel user) async {
    final res = await _client
        .from('users')
        .insert(user.toJson())
        .select()
        .single();
    return UserModel.fromJson(res);
  }

  // ==================== PRODUCTS ====================
  static Future<List<ProductModel>> getProducts() async {
    final res = await _client
        .from('products')
        .select()
        .order('created_at', ascending: true);
    return (res as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  // ==================== STOCK ====================
  /// คำนวณสต็อกปัจจุบันแต่ละสินค้า จาก stock_transactions
  static Future<Map<String, int>> getCurrentStock() async {
    final res = await _client
        .from('stock_transactions')
        .select('product_id, type, quantity');

    final Map<String, int> stock = {};
    for (final row in res as List) {
      final pid = row['product_id'] as String;
      final qty = row['quantity'] as int;
      final type = row['type'] as String;
      stock[pid] = (stock[pid] ?? 0) + (type == 'in' ? qty : -qty);
    }
    return stock;
  }

  static Future<List<StockTransaction>> getStockTransactions() async {
    final res = await _client
        .from('stock_transactions')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    return (res as List).map((e) => StockTransaction.fromJson({
      ...e,
      'product_name': e['product_name'] ?? '',
    })).toList();
  }

  static Future<void> addStockTransaction({
    required String productId,
    required String productName,
    required String type,
    required int quantity,
    String? note,
    String? createdBy,
  }) async {
    await _client.from('stock_transactions').insert({
      'product_id': productId,
      'product_name': productName,
      'type': type,
      'quantity': quantity,
      'note': note,
      'created_by': createdBy ?? 'admin',
    });
  }

  // ==================== ORDERS ====================
  static Future<List<OrderModel>> getOrders() async {
    final ordersRes = await _client
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);

    return (ordersRes as List).map((o) {
      final items = (o['order_items'] as List? ?? []).map((i) => OrderItem(
        id: i['id'] as String,
        orderId: o['id'] as String,
        productId: i['product_id'] as String,
        productName: i['product_name'] as String,
        quantity: i['quantity'] as int,
        pricePerUnit: (i['price_per_unit'] as num).toDouble(),
        subtotal: (i['subtotal'] as num).toDouble(),
      )).toList();

      return OrderModel(
        id: o['id'] as String,
        orderNumber: o['order_number'] as String,
        customerId: o['customer_id'] as String? ?? '',
        customerName: o['customer_name'] as String,
        status: o['status'] as String,
        totalAmount: (o['total_amount'] as num).toDouble(),
        deliveryAddress: o['delivery_address'] as String,
        deliveryDate: DateTime.parse(o['delivery_date'] as String),
        note: o['note'] as String?,
        proofPhotoUrl: o['proof_photo_url'] as String?,
        deliveredAt: o['delivered_at'] != null
            ? DateTime.parse(o['delivered_at'] as String)
            : null,
        createdAt: DateTime.parse(o['created_at'] as String),
        items: items,
      );
    }).toList();
  }

  static Future<OrderModel> createOrder(OrderModel order) async {
    // 1. Insert order
    final orderRes = await _client.from('orders').insert({
      'order_number': order.orderNumber,
      'customer_id': order.customerId,
      'customer_name': order.customerName,
      'status': order.status,
      'total_amount': order.totalAmount,
      'delivery_address': order.deliveryAddress,
      'delivery_date': order.deliveryDate.toIso8601String().split('T').first,
      'note': order.note,
    }).select().single();

    final orderId = orderRes['id'] as String;

    // 2. Insert items
    final itemsData = order.items.map((i) => {
      'order_id': orderId,
      'product_id': i.productId,
      'product_name': i.productName,
      'quantity': i.quantity,
      'price_per_unit': i.pricePerUnit,
      'subtotal': i.subtotal,
    }).toList();

    await _client.from('order_items').insert(itemsData);

    // 3. Deduct stock
    for (final item in order.items) {
      await addStockTransaction(
        productId: item.productId,
        productName: item.productName,
        type: 'out',
        quantity: item.quantity,
        note: 'ส่งให้ ${order.customerName} (${order.orderNumber})',
        createdBy: 'admin',
      );
    }

    return order.copyWith(id: orderId);
  }

  static Future<void> updateOrderStatus(
    String orderId,
    String status, {
    String? proofPhotoUrl,
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (proofPhotoUrl != null) data['proof_photo_url'] = proofPhotoUrl;
    if (status == 'delivered') data['delivered_at'] = DateTime.now().toIso8601String();

    await _client.from('orders').update(data).eq('id', orderId);
  }

  // ==================== STORAGE ====================
  static Future<String?> uploadDeliveryProof(
    String orderId,
    File imageFile,
  ) async {
    try {
      final ext = imageFile.path.split('.').last;
      final path = 'orders/$orderId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _client.storage
          .from('delivery-proofs')
          .upload(path, imageFile, fileOptions: const FileOptions(upsert: true));

      final url = _client.storage
          .from('delivery-proofs')
          .getPublicUrl(path);

      return url;
    } catch (e) {
      return null;
    }
  }
}
