class StockTransaction {
  final String id;
  final String productId;
  final String productName;
  final String type; // 'in' | 'out'
  final int quantity;
  final String? note;
  final String createdBy;
  final DateTime createdAt;

  const StockTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    this.note,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isIn => type == 'in';

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      type: json['type'] as String,
      quantity: json['quantity'] as int,
      note: json['note'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
