import '../models/transaction_model.dart';

/*
REAL API IMPLEMENTATION GUIDE:
1) Inject an HTTP client (Dio/http) via constructor for testing.
2) Map methods to endpoints:
   - getMyPurchases(userId) -> GET /marketplace/purchases
   - getMySales(userId)     -> GET /marketplace/sales
   - getTransactionById(id) -> GET /marketplace/transactions/{id}
   - createTransaction(...) -> POST /marketplace/transactions
   - updateTransactionStatus(id,status) -> PATCH /marketplace/transactions/{id}/status
3) Replace dummy lists with parsed JSON into TransactionModel.fromJson.
4) Handle errors (timeout/no internet/server) and return meaningful messages.
5) Keep async signatures to match the presentation layer expectations.
*/
class TransactionService {
  // Example: TransactionService(this._httpClient);
  // final Dio _httpClient;

  Future<List<TransactionModel>> getMyPurchases(String userId) async {
    return [
      TransactionModel(
        id: 'trx-1',
        productId: 'prod-1',
        productName: 'Batik Parang Rusak',
        productImage:
            'https://images.unsplash.com/photo-1622011276089-7db291e780d6?w=500',
        buyerId: userId,
        buyerName: 'Current User',
        sellerId: 'user-1',
        sellerName: 'Sri Wijaya',
        quantity: 2,
        price: 250000,
        totalAmount: 500000,
        status: TransactionStatus.pending,
        transactionDate: DateTime.now().subtract(const Duration(hours: 2)),
        notes: 'Menunggu pembayaran',
        paymentProof: null,
        paymentBank: 'BCA',
      ),
      TransactionModel(
        id: 'trx-2',
        productId: 'prod-2',
        productName: 'Batik Mega Mendung',
        productImage:
            'https://images.unsplash.com/photo-1610201303973-1d3794b9b043?w=500',
        buyerId: userId,
        buyerName: 'Current User',
        sellerId: 'user-2',
        sellerName: 'Rizky Pratama',
        quantity: 1,
        price: 175000,
        totalAmount: 175000,
        status: TransactionStatus.processing,
        transactionDate: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Sedang dalam proses pengiriman',
        paymentProof:
            'https://placehold.co/600x400/10b981/ffffff?text=Bukti+Transfer',
        paymentBank: 'BCA',
      ),
      TransactionModel(
        id: 'trx-3',
        productId: 'prod-4',
        productName: 'Batik Sekar Jagad',
        productImage:
            'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=500',
        buyerId: userId,
        buyerName: 'Current User',
        sellerId: 'user-3',
        sellerName: 'Dewi Anggraini',
        quantity: 1,
        price: 300000,
        totalAmount: 300000,
        status: TransactionStatus.completed,
        transactionDate: DateTime.now().subtract(const Duration(days: 7)),
        completedDate: DateTime.now().subtract(const Duration(days: 5)),
        notes: 'Pesanan telah diterima dengan baik',
        paymentProof:
            'https://placehold.co/600x400/10b981/ffffff?text=Bukti+Transfer',
        paymentBank: 'BCA',
      ),
    ];
  }

  Future<List<TransactionModel>> getMySales(String userId) async {
    return [
      TransactionModel(
        id: 'trx-4',
        productId: 'prod-1',
        productName: 'Batik Parang Rusak',
        productImage:
            'https://images.unsplash.com/photo-1622011276089-7db291e780d6?w=500',
        buyerId: 'user-5',
        buyerName: 'Ahmad Hidayat',
        sellerId: userId,
        sellerName: 'Current User',
        quantity: 2,
        price: 225000,
        totalAmount: 450000,
        status: TransactionStatus.pending,
        transactionDate: DateTime.now().subtract(const Duration(hours: 3)),
        notes: 'Mohon segera diproses',
        paymentProof:
            'https://placehold.co/600x400/e2e8f0/64748b?text=Bukti+Pembayaran',
        paymentBank: 'BCA',
      ),
      TransactionModel(
        id: 'trx-5',
        productId: 'prod-1',
        productName: 'Batik Parang Rusak',
        productImage:
            'https://images.unsplash.com/photo-1622011276089-7db291e780d6?w=500',
        buyerId: 'user-6',
        buyerName: 'Siti Nurhaliza',
        sellerId: userId,
        sellerName: 'Current User',
        quantity: 1,
        price: 225000,
        totalAmount: 225000,
        status: TransactionStatus.processing,
        transactionDate: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Pengiriman via JNE',
        paymentProof:
            'https://placehold.co/600x400/e2e8f0/64748b?text=Bukti+Pembayaran',
        paymentBank: 'BCA',
      ),
      TransactionModel(
        id: 'trx-6',
        productId: 'prod-1',
        productName: 'Batik Parang Rusak',
        productImage:
            'https://images.unsplash.com/photo-1622011276089-7db291e780d6?w=500',
        buyerId: 'user-7',
        buyerName: 'Budi Santoso',
        sellerId: userId,
        sellerName: 'Current User',
        quantity: 3,
        price: 225000,
        totalAmount: 675000,
        status: TransactionStatus.completed,
        transactionDate: DateTime.now().subtract(const Duration(days: 7)),
        completedDate: DateTime.now().subtract(const Duration(days: 5)),
        notes: 'Terima kasih',
        paymentProof:
            'https://placehold.co/600x400/e2e8f0/64748b?text=Bukti+Pembayaran',
        paymentBank: 'BCA',
      ),
      TransactionModel(
        id: 'trx-7',
        productId: 'prod-1',
        productName: 'Batik Parang Rusak',
        productImage:
            'https://images.unsplash.com/photo-1622011276089-7db291e780d6?w=500',
        buyerId: 'user-8',
        buyerName: 'Dewi Lestari',
        sellerId: userId,
        sellerName: 'Current User',
        quantity: 1,
        price: 225000,
        totalAmount: 225000,
        status: TransactionStatus.cancelled,
        transactionDate: DateTime.now().subtract(const Duration(days: 3)),
        notes: 'Stok tidak tersedia',
        paymentProof:
            'https://placehold.co/600x400/e2e8f0/64748b?text=Bukti+Pembayaran',
        paymentBank: 'BCA',
      ),
      TransactionModel(
        id: 'trx-8',
        productId: 'prod-3',
        productName: 'Batik Kawung',
        productImage:
            'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=500',
        buyerId: 'user-9',
        buyerName: 'Rudi Hermawan',
        sellerId: userId,
        sellerName: 'Current User',
        quantity: 2,
        price: 200000,
        totalAmount: 400000,
        status: TransactionStatus.pending,
        transactionDate: DateTime.now().subtract(const Duration(hours: 8)),
        notes: 'Butuh cepat',
        paymentProof:
            'https://placehold.co/600x400/e2e8f0/64748b?text=Bukti+Pembayaran',
        paymentBank: 'BCA',
      ),
    ];
  }

  Future<TransactionModel> getTransactionById(String id) async {
    final purchases = await getMyPurchases('current-user');
    return purchases.firstWhere(
      (trx) => trx.id == id,
      orElse: () => throw Exception('Transaction not found'),
    );
  }

  Future<TransactionModel> createTransaction({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    return TransactionModel(
      id: 'trx-new-${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      productName: 'Product Name',
      productImage: 'https://via.placeholder.com/150',
      buyerId: 'current-user',
      buyerName: 'Current User',
      sellerId: 'seller-id',
      sellerName: 'Seller Name',
      quantity: quantity,
      price: 0,
      totalAmount: 0,
      status: TransactionStatus.pending,
      transactionDate: DateTime.now(),
      notes: notes,
      paymentBank: 'BCA',
    );
  }

  Future<TransactionModel> updateTransactionStatus(
    String id,
    TransactionStatus status,
  ) async {
    final transaction = await getTransactionById(id);
    return transaction.copyWith(
      status: status,
      completedDate: status == TransactionStatus.completed
          ? DateTime.now()
          : null,
    );
  }
}
