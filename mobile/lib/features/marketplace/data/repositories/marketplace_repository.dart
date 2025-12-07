import '../services/marketplace_service.dart';
import '../models/product_model.dart';

/// Repository untuk Marketplace
///
/// Repository bertindak sebagai abstraction layer antara data source dan presentation layer.
/// Ini memudahkan untuk:
/// - Switching antara different data sources (API, local DB, cache)
/// - Testing (bisa mock repository dengan mudah)
/// - Business logic yang lebih bersih
class MarketplaceRepository {
  final MarketplaceService _service;

  MarketplaceRepository({MarketplaceService? service})
    : _service = service ?? MarketplaceService();

  Future<List<String>> getCategories() async {
    try {
      return await _service.getCategories();
    } catch (e) {
      throw Exception('Gagal memuat kategori: $e');
    }
  }

  /// Get semua produk
  Future<List<ProductModel>> getProducts() async {
    try {
      return await _service.getProducts();
    } catch (e) {
      throw Exception('Gagal memuat produk: $e');
    }
  }

  /// Get detail produk
  Future<ProductModel> getProductById(String id) async {
    try {
      return await _service.getProductById(id);
    } catch (e) {
      throw Exception('Gagal memuat detail produk: $e');
    }
  }

  /// Get produk milik user
  Future<List<ProductModel>> getMyProducts(String userId) async {
    try {
      return await _service.getMyProducts(userId);
    } catch (e) {
      throw Exception('Gagal memuat produk saya: $e');
    }
  }

  /// Tambah produk baru
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      return await _service.createProduct(product);
    } catch (e) {
      throw Exception('Gagal menambah produk: $e');
    }
  }

  /// Update produk
  Future<ProductModel> updateProduct(String id, ProductModel product) async {
    try {
      return await _service.updateProduct(id, product);
    } catch (e) {
      throw Exception('Gagal mengupdate produk: $e');
    }
  }

  /// Hapus produk
  Future<void> deleteProduct(String id) async {
    try {
      await _service.deleteProduct(id);
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }

  /// Search produk
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        return await getProducts();
      }
      return await _service.searchProducts(query);
    } catch (e) {
      throw Exception('Gagal mencari produk: $e');
    }
  }

  /// Filter by category
  Future<List<ProductModel>> filterByCategory(String category) async {
    try {
      return await _service.filterByCategory(category);
    } catch (e) {
      throw Exception('Gagal memfilter produk: $e');
    }
  }
}
