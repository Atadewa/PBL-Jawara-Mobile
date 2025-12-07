import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Model untuk Transaction dari API
/// 
/// Model ini merepresentasikan data transaksi pembelian/penjualan
class TransactionModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final int quantity;
  final double price;
  final double totalAmount;
  final TransactionStatus status;
  final DateTime transactionDate;
  final DateTime? completedDate;
  final String? notes;
  final String? paymentProof;
  final String? paymentBank;

  TransactionModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.status,
    required this.transactionDate,
    this.completedDate,
    this.notes,
    this.paymentProof,
    this.paymentBank,
  });

  /// Factory constructor untuk parsing dari JSON
  ///
  /// Contoh response API:
  /// ```json
  /// {
  ///   "id": "trx-123",
  ///   "product_id": "prod-456",
  ///   "product_name": "Batik Parang",
  ///   "product_image": "https://api.example.com/images/batik1.jpg",
  ///   "buyer_id": "user-789",
  ///   "buyer_name": "John Doe",
  ///   "seller_id": "user-456",
  ///   "seller_name": "Sri Wijaya",
  ///   "quantity": 2,
  ///   "price": 150000,
  ///   "total_amount": 300000,
  ///   "status": "completed",
  ///   "transaction_date": "2024-01-15T10:30:00Z",
  ///   "completed_date": "2024-01-15T14:30:00Z",
  ///   "notes": "Pengiriman via JNE"
  /// }
  /// ```
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      buyerId: json['buyer_id'] as String,
      buyerName: json['buyer_name'] as String,
      sellerId: json['seller_id'] as String,
      sellerName: json['seller_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: _parseStatus(json['status'] as String),
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      notes: json['notes'] as String?,
      paymentProof: json['payment_proof'] as String?,
      paymentBank: json['payment_bank'] as String?,
    );
  }

  /// Convert status string ke enum
  static TransactionStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'processing':
        return TransactionStatus.processing;
      case 'completed':
        return TransactionStatus.completed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  /// Convert model ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'quantity': quantity,
      'price': price,
      'total_amount': totalAmount,
      'status': status.name,
      'transaction_date': transactionDate.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'notes': notes,
      'payment_proof': paymentProof,
      'payment_bank': paymentBank,
    };
  }

  /// Copy with method
  TransactionModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    String? buyerId,
    String? buyerName,
    String? sellerId,
    String? sellerName,
    int? quantity,
    double? price,
    double? totalAmount,
    TransactionStatus? status,
    DateTime? transactionDate,
    DateTime? completedDate,
    String? notes,
    String? paymentProof,
    String? paymentBank,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      transactionDate: transactionDate ?? this.transactionDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      paymentProof: paymentProof ?? this.paymentProof,
      paymentBank: paymentBank ?? this.paymentBank,
    );
  }
}

/// Enum untuk status transaksi
enum TransactionStatus { pending, processing, completed, cancelled }

/// Extension untuk mendapatkan label status dalam bahasa Indonesia
extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'Menunggu';
      case TransactionStatus.processing:
        return 'Diproses';
      case TransactionStatus.completed:
        return 'Selesai';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.pending:
        return AppColors.warningBright;
      case TransactionStatus.processing:
        return AppColors.info;
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.cancelled:
        return AppColors.error;
    }
  }
}
