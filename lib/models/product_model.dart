class ProductModel {
  final String id;
  final String name;
  final String unit;
  final double pricePerUnit;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.pricePerUnit,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      pricePerUnit: (json['price_per_unit'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unit': unit,
    'price_per_unit': pricePerUnit,
    'image_url': imageUrl,
  };
}
