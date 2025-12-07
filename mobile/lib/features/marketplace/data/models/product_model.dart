/// Model untuk Product dari API
///
/// Model ini merepresentasikan data produk batik yang diterima dari backend.
/// Gunakan model ini untuk parsing JSON response dari API.
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor untuk parsing dari JSON
  ///
  /// Ketika mengintegrasikan dengan API real, sesuaikan field names
  /// dengan yang dikirimkan oleh backend
  ///
  /// Contoh response API:
  /// ```json
  /// {
  ///   "id": "prod-123",
  ///   "name": "Batik Parang",
  ///   "description": "Batik motif parang rusak",
  ///   "price": 150000,
  ///   "image_url": "https://api.example.com/images/batik1.jpg",
  ///   "category": "Batik Tulis",
  ///   "stock": 10,
  ///   "seller_id": "user-456",
  ///   "seller_name": "Sri Wijaya",
  ///   "created_at": "2024-01-15T10:30:00Z",
  ///   "updated_at": "2024-01-15T10:30:00Z"
  /// }
  /// ```
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      category: json['category'] as String,
      stock: json['stock'] as int,
      sellerId: json['seller_id'] as String,
      sellerName: json['seller_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert model ke JSON untuk request ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'stock': stock,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method untuk immutability
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stock,
    String? sellerId,
    String? sellerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
