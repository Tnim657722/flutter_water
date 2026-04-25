import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/stock_model.dart';
import '../models/order_model.dart';

class MockDataService {
  // ==================== USERS ====================
  static List<UserModel> get users => [
    const UserModel(
      id: 'u1',
      username: 'admin',
      password: 'admin',
      role: 'admin',
      fullName: 'ผู้ดูแลระบบ',
      phone: '081-000-0000',
      address: 'โรงงาน AquaFlow กรุงเทพฯ',
    ),
    const UserModel(
      id: 'u2',
      username: 'somchai',
      password: '1234',
      role: 'customer',
      fullName: 'สมชาย ใจดี',
      phone: '081-234-5678',
      address: '123 ถ.สุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
    ),
    const UserModel(
      id: 'u3',
      username: 'malee',
      password: '1234',
      role: 'customer',
      fullName: 'มาลี รักดี',
      phone: '082-345-6789',
      address: '456 ถ.พระราม 9 แขวงห้วยขวาง เขตห้วยขวาง กรุงเทพฯ 10310',
    ),
    const UserModel(
      id: 'u4',
      username: 'wanchai',
      password: '1234',
      role: 'customer',
      fullName: 'วันชัย ธุรกิจดี',
      phone: '083-456-7890',
      address: '789 ถ.รัชดาภิเษก แขวงดินแดง เขตดินแดง กรุงเทพฯ 10400',
    ),
  ];

  static UserModel? login(String username, String password) {
    try {
      return users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  // ==================== PRODUCTS ====================
  static List<ProductModel> get products => [
    const ProductModel(
      id: 'p1',
      name: 'น้ำดื่ม 600ml',
      unit: 'แพค (12 ขวด)',
      pricePerUnit: 60.0,
      imageUrl: null,
    ),
    const ProductModel(
      id: 'p2',
      name: 'น้ำดื่ม 1.5L',
      unit: 'แพค (6 ขวด)',
      pricePerUnit: 75.0,
      imageUrl: null,
    ),
    const ProductModel(
      id: 'p3',
      name: 'น้ำดื่ม 5L',
      unit: 'ถัง',
      pricePerUnit: 25.0,
      imageUrl: null,
    ),
    const ProductModel(
      id: 'p4',
      name: 'น้ำดื่ม 18.9L',
      unit: 'ถัง',
      pricePerUnit: 35.0,
      imageUrl: null,
    ),
  ];

  // ==================== STOCK ====================
  static Map<String, int> get currentStock => {
    'p1': 150,
    'p2': 80,
    'p3': 45,
    'p4': 20,
  };

  static List<StockTransaction> get stockTransactions => [
    StockTransaction(
      id: 'st1',
      productId: 'p1',
      productName: 'น้ำดื่ม 600ml',
      type: 'in',
      quantity: 200,
      note: 'รับจากโรงงาน บริษัท ABC',
      createdBy: 'admin',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    StockTransaction(
      id: 'st2',
      productId: 'p2',
      productName: 'น้ำดื่ม 1.5L',
      type: 'in',
      quantity: 100,
      note: 'รับจากโรงงาน บริษัท ABC',
      createdBy: 'admin',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    StockTransaction(
      id: 'st3',
      productId: 'p1',
      productName: 'น้ำดื่ม 600ml',
      type: 'out',
      quantity: 50,
      note: 'ส่งให้ สมชาย ใจดี (ORD-2024-001)',
      createdBy: 'admin',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    StockTransaction(
      id: 'st4',
      productId: 'p3',
      productName: 'น้ำดื่ม 5L',
      type: 'in',
      quantity: 60,
      note: 'รับจากโรงงาน',
      createdBy: 'admin',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  // ==================== ORDERS ====================
  static List<OrderModel> get orders => [
    OrderModel(
      id: 'o1',
      orderNumber: 'AQ-2024-001',
      customerId: 'u2',
      customerName: 'สมชาย ใจดี',
      status: 'delivered',
      totalAmount: 3000.0,
      deliveryAddress: '123 ถ.สุขุมวิท แขวงคลองเตย กรุงเทพฯ',
      deliveryDate: DateTime.now().subtract(const Duration(days: 1)),
      note: 'ส่งถึงหน้าร้าน โทรก่อน 30 นาที',
      items: [
        OrderItem(
          id: 'oi1',
          orderId: 'o1',
          productId: 'p1',
          productName: 'น้ำดื่ม 600ml',
          quantity: 30,
          pricePerUnit: 60.0,
          subtotal: 1800.0,
        ),
        OrderItem(
          id: 'oi2',
          orderId: 'o1',
          productId: 'p2',
          productName: 'น้ำดื่ม 1.5L',
          quantity: 16,
          pricePerUnit: 75.0,
          subtotal: 1200.0,
        ),
      ],
      proofPhotoUrl: null,
      deliveredAt: DateTime.now().subtract(const Duration(hours: 20)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrderModel(
      id: 'o2',
      orderNumber: 'AQ-2024-002',
      customerId: 'u3',
      customerName: 'มาลี รักดี',
      status: 'delivering',
      totalAmount: 1500.0,
      deliveryAddress: '456 ถ.พระราม 9 แขวงห้วยขวาง กรุงเทพฯ',
      deliveryDate: DateTime.now(),
      note: null,
      items: [
        OrderItem(
          id: 'oi3',
          orderId: 'o2',
          productId: 'p3',
          productName: 'น้ำดื่ม 5L',
          quantity: 20,
          pricePerUnit: 25.0,
          subtotal: 500.0,
        ),
        OrderItem(
          id: 'oi4',
          orderId: 'o2',
          productId: 'p4',
          productName: 'น้ำดื่ม 18.9L',
          quantity: 20,
          pricePerUnit: 35.0,
          subtotal: 700.0,
        ),
        OrderItem(
          id: 'oi5',
          orderId: 'o2',
          productId: 'p1',
          productName: 'น้ำดื่ม 600ml',
          quantity: 5,
          pricePerUnit: 60.0,
          subtotal: 300.0,
        ),
      ],
      proofPhotoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    OrderModel(
      id: 'o3',
      orderNumber: 'AQ-2024-003',
      customerId: 'u4',
      customerName: 'วันชัย ธุรกิจดี',
      status: 'pending',
      totalAmount: 875.0,
      deliveryAddress: '789 ถ.รัชดาภิเษก แขวงดินแดง กรุงเทพฯ',
      deliveryDate: DateTime.now().add(const Duration(days: 1)),
      note: 'โทรนัดก่อนส่ง',
      items: [
        OrderItem(
          id: 'oi6',
          orderId: 'o3',
          productId: 'p4',
          productName: 'น้ำดื่ม 18.9L',
          quantity: 25,
          pricePerUnit: 35.0,
          subtotal: 875.0,
        ),
      ],
      proofPhotoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    OrderModel(
      id: 'o4',
      orderNumber: 'AQ-2024-004',
      customerId: 'u2',
      customerName: 'สมชาย ใจดี',
      status: 'assigned',
      totalAmount: 1200.0,
      deliveryAddress: '123 ถ.สุขุมวิท แขวงคลองเตย กรุงเทพฯ',
      deliveryDate: DateTime.now().add(const Duration(days: 2)),
      note: null,
      items: [
        OrderItem(
          id: 'oi7',
          orderId: 'o4',
          productId: 'p1',
          productName: 'น้ำดื่ม 600ml',
          quantity: 20,
          pricePerUnit: 60.0,
          subtotal: 1200.0,
        ),
      ],
      proofPhotoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];
}
