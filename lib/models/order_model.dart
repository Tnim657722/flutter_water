class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double pricePerUnit;
  final double subtotal;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
    required this.subtotal,
  });
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String status; // pending | assigned | delivering | delivered | cancelled
  final double totalAmount;
  final String deliveryAddress;
  final DateTime deliveryDate;
  final String? note;
  final List<OrderItem> items;
  final String? proofPhotoUrl;
  final DateTime? deliveredAt;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.deliveryDate,
    this.note,
    required this.items,
    this.proofPhotoUrl,
    this.deliveredAt,
    required this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'assigned':
        return 'มอบหมายแล้ว';
      case 'delivering':
        return 'กำลังส่ง';
      case 'delivered':
        return 'ส่งสำเร็จ';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status;
    }
  }

  int get statusIndex {
    switch (status) {
      case 'pending': return 0;
      case 'assigned': return 1;
      case 'delivering': return 2;
      case 'delivered': return 3;
      default: return 0;
    }
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? status,
    double? totalAmount,
    String? deliveryAddress,
    DateTime? deliveryDate,
    String? note,
    List<OrderItem>? items,
    String? proofPhotoUrl,
    DateTime? deliveredAt,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      note: note ?? this.note,
      items: items ?? this.items,
      proofPhotoUrl: proofPhotoUrl ?? this.proofPhotoUrl,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
