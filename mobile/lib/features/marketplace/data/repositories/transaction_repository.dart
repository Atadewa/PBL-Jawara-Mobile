import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

/// Repository untuk Transaksi Marketplace
class TransactionRepository {
  final TransactionService _service;

  TransactionRepository({TransactionService? service})
    : _service = service ?? TransactionService();

  /// Get riwayat pembelian
  Future<List<TransactionModel>> getMyPurchases(String userId) async {
    try {
      return await _service.getMyPurchases(userId);
    } catch (e) {
      throw Exception('Gagal memuat riwayat pembelian: $e');
    }
  }

  /// Get riwayat penjualan
  Future<List<TransactionModel>> getMySales(String userId) async {
    try {
      return await _service.getMySales(userId);
    } catch (e) {
      throw Exception('Gagal memuat riwayat penjualan: $e');
    }
  }

  /// Get detail transaksi
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      return await _service.getTransactionById(id);
    } catch (e) {
      throw Exception('Gagal memuat detail transaksi: $e');
    }
  }

  /// Buat transaksi baru
  Future<TransactionModel> createTransaction({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    try {
      return await _service.createTransaction(
        productId: productId,
        quantity: quantity,
        notes: notes,
      );
    } catch (e) {
      throw Exception('Gagal membuat transaksi: $e');
    }
  }

  /// Update status transaksi
  Future<TransactionModel> updateTransactionStatus(
    String id,
    TransactionStatus status,
  ) async {
    try {
      return await _service.updateTransactionStatus(id, status);
    } catch (e) {
      throw Exception('Gagal mengupdate status transaksi: $e');
    }
  }
}
