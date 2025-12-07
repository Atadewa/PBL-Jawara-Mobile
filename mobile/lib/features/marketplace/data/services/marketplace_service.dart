import '../models/product_model.dart';

/*
REAL API IMPLEMENTATION GUIDE (replace dummy data below):
1) Inject an HTTP client (Dio/http) via the constructor for testability.
2) Wire each method to the real endpoint:
   - getProducts()         -> GET /marketplace/products
   - getProductById(id)    -> GET /marketplace/products/{id}
   - getMyProducts(userId) -> GET /marketplace/my-products
   - createProduct(body)   -> POST /marketplace/products
   - updateProduct(id)     -> PUT /marketplace/products/{id}
   - deleteProduct(id)     -> DELETE /marketplace/products/{id}
   - searchProducts(q)     -> GET /marketplace/products/search?q={query}
   - filterByCategory(cat) -> GET /marketplace/products?category={cat}
3) Replace the dummy list with JSON parsing into ProductModel.fromJson.
4) Handle timeouts/no-internet/server errors with try/catch and meaningful messages.
5) Keep the async signatures so the UI flow stays the same.
*/
class MarketplaceService {
  // Example: MarketplaceService(this._httpClient);
  // final Dio _httpClient;

  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['Batik Tulis', 'Batik Cap'];
  }

  Future<List<ProductModel>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      ProductModel(
        id: 'prod-1',
        name: 'Batik Parang Rusak',
        description:
            'Batik tulis motif parang rusak dengan kualitas premium. Cocok untuk acara formal dan resmi.',
        price: 250000,
        imageUrl:
            'https://images.unsplash.com/photo-1622011276089-7db291e780d6?w=500',
        category: 'Batik Tulis',
        stock: 5,
        sellerId: 'user-1',
        sellerName: 'Sri Wijaya',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ProductModel(
        id: 'prod-2',
        name: 'Batik Mega Mendung',
        description:
            'Batik cap dengan motif mega mendung khas Cirebon. Warna cerah dan menarik.',
        price: 175000,
        imageUrl:
            'https://images.unsplash.com/photo-1610201303973-1d3794b9b043?w=500',
        category: 'Batik Cap',
        stock: 10,
        sellerId: 'user-2',
        sellerName: 'Rizky Pratama',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ProductModel(
        id: 'prod-3',
        name: 'Batik Kawung',
        description:
            'Batik motif kawung yang elegan. Cocok untuk berbagai acara.',
        price: 200000,
        imageUrl:
            'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=500',
        category: 'Batik Tulis',
        stock: 8,
        sellerId: 'user-1',
        sellerName: 'Sri Wijaya',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProductModel(
        id: 'prod-4',
        name: 'Batik Sekar Jagad',
        description: 'Batik kombinasi dengan berbagai motif dalam satu kain.',
        price: 300000,
        imageUrl:
            'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=500',
        category: 'Batik Tulis',
        stock: 3,
        sellerId: 'user-3',
        sellerName: 'Dewi Anggraini',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ProductModel(
        id: 'prod-5',
        name: 'Batik Pekalongan',
        description: 'Batik khas Pekalongan dengan warna-warna cerah.',
        price: 150000,
        imageUrl:
            'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=500',
        category: 'Batik Cap',
        stock: 15,
        sellerId: 'user-2',
        sellerName: 'Rizky Pratama',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      ProductModel(
        id: 'prod-6',
        name: 'Batik Truntum',
        description:
            'Batik motif truntum yang melambangkan cinta yang tumbuh kembali.',
        price: 225000,
        imageUrl:
            'https://images.unsplash.com/photo-1591361892149-8ffa6a2a1f16?w=500',
        category: 'Batik Tulis',
        stock: 6,
        sellerId: 'user-3',
        sellerName: 'Dewi Anggraini',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  Future<ProductModel> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final products = await getProducts();
    return products.firstWhere(
      (product) => product.id == id,
      orElse: () => throw Exception('Product not found'),
    );
  }

  Future<List<ProductModel>> getMyProducts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final allProducts = await getProducts();
    return allProducts.where((p) => p.sellerId == userId).toList();
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return product;
  }

  Future<ProductModel> updateProduct(String id, ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return product;
  }

  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final allProducts = await getProducts();
    final lowerQuery = query.toLowerCase();

    return allProducts.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<ProductModel>> filterByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final allProducts = await getProducts();
    return allProducts.where((p) => p.category == category).toList();
  }
}
