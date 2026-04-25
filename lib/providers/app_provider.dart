import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/stock_model.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  UserModel? _currentUser;
  List<OrderModel> _orders = [];
  Map<String, int> _stock = {};
  List<StockTransaction> _stockTransactions = [];
  List<UserModel> _customers = [];
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  List<OrderModel> get orders => _orders;
  Map<String, int> get stock => _stock;
  List<StockTransaction> get stockTransactions => _stockTransactions;
  List<UserModel> get customers => _customers;
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Dashboard stats
  int get pendingOrdersCount =>
      _orders.where((o) => o.status == 'pending' || o.status == 'assigned').length;
  int get deliveringCount =>
      _orders.where((o) => o.status == 'delivering').length;
  int get deliveredTodayCount {
    final today = DateTime.now();
    return _orders.where((o) =>
      o.status == 'delivered' &&
      o.deliveredAt != null &&
      o.deliveredAt!.day == today.day &&
      o.deliveredAt!.month == today.month
    ).length;
  }

  int getTotalStock() => _stock.values.fold(0, (s, v) => s + (v > 0 ? v : 0));
  int getStockForProduct(String productId) => _stock[productId] ?? 0;

  List<OrderModel> getOrdersForCustomer(String customerId) =>
      _orders.where((o) => o.customerId == customerId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // ==================== AUTH ====================
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await SupabaseService.login(username, password);
      if (user != null) {
        _currentUser = user;
        await _loadAllData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'เชื่อมต่อไม่ได้: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    _orders = [];
    _stock = {};
    _stockTransactions = [];
    _customers = [];
    notifyListeners();
  }

  // ==================== DATA LOADING ====================
  Future<void> _loadAllData() async {
    await Future.wait([
      _loadProducts(),
      _loadOrders(),
      _loadStock(),
      if (isAdmin) _loadCustomers() else Future.value(),
    ]);
  }

  Future<void> refreshData() async {
    _setLoading(true);
    await _loadAllData();
    _setLoading(false);
  }

  Future<void> _loadProducts() async {
    _products = await SupabaseService.getProducts();
  }

  Future<void> _loadOrders() async {
    _orders = await SupabaseService.getOrders();
  }

  Future<void> _loadStock() async {
    _stock = await SupabaseService.getCurrentStock();
    _stockTransactions = await SupabaseService.getStockTransactions();
  }

  Future<void> _loadCustomers() async {
    _customers = await SupabaseService.getCustomers();
  }

  // ==================== STOCK ====================
  Future<void> addStock(String productId, int quantity, String note) async {
    final product = _products.firstWhere((p) => p.id == productId);
    await SupabaseService.addStockTransaction(
      productId: productId,
      productName: product.name,
      type: 'in',
      quantity: quantity,
      note: note,
      createdBy: _currentUser?.fullName ?? 'admin',
    );
    await _loadStock();
    notifyListeners();
  }

  // ==================== ORDERS ====================
  Future<void> addOrder(OrderModel order) async {
    final created = await SupabaseService.createOrder(order);
    _orders.insert(0, created);
    await _loadStock(); // refresh stock after deduction
    notifyListeners();
  }

  Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? proofPhotoUrl,
  }) async {
    await SupabaseService.updateOrderStatus(
      orderId,
      newStatus,
      proofPhotoUrl: proofPhotoUrl,
    );

    // Update local state
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final old = _orders[idx];
      _orders[idx] = old.copyWith(
        status: newStatus,
        proofPhotoUrl: proofPhotoUrl ?? old.proofPhotoUrl,
        deliveredAt: newStatus == 'delivered' ? DateTime.now() : old.deliveredAt,
      );
      notifyListeners();
    }
  }

  // ==================== CUSTOMERS ====================
  Future<void> addCustomer(UserModel customer) async {
    final created = await SupabaseService.addCustomer(customer);
    _customers.insert(0, created);
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
