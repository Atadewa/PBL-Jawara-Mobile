import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../widgets/empty_state_widget.dart';
import 'transaction_detail_page.dart';

/// Halaman Riwayat Pembeli untuk produk tertentu
class ProductBuyersPage extends StatefulWidget {
  final ProductModel product;

  const ProductBuyersPage({super.key, required this.product});

  @override
  State<ProductBuyersPage> createState() => _ProductBuyersPageState();
}

class _ProductBuyersPageState extends State<ProductBuyersPage> {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get all sales transactions
      final allSales = await _repository.getMySales(widget.product.sellerId);

      // Filter by product ID
      final productTransactions = allSales
          .where((transaction) => transaction.productId == widget.product.id)
          .toList();

      if (!mounted) return;

      setState(() {
        _transactions = productTransactions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.50, 0.00),
                end: Alignment(0.50, 1.00),
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Back button
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.background,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Riwayat Pembeli',
                          style: TextStyle(
                            color: AppColors.background,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Daftar pembeli produk ${widget.product.name}',
                    style: TextStyle(
                      color: AppColors.background.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transactions List
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.success),
      );
    }

    if (_errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Terjadi Kesalahan',
        message: _errorMessage!,
        actionText: 'Coba Lagi',
        onActionPressed: _loadTransactions,
      );
    }

    if (_transactions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'Belum Ada Pembeli',
        message: 'Produk ini belum memiliki pembeli',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: AppColors.success,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildTransactionCard(_transactions[index]);
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final hasMultipleProducts = transaction.quantity > 1;

    return InkWell(
      onTap: () => _navigateToDetail(transaction),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(width: 1, color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 6,
              offset: const Offset(0, 4),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buyer Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: Center(
                child: Text(
                  transaction.buyerName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Transaction Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buyer name and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.buyerName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            transaction.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.status.label,
                          style: TextStyle(
                            color: _getStatusColor(transaction.status),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Product info and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hasMultipleProducts
                              ? '${transaction.quantity}x ${widget.product.name}'
                              : widget.product.name,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatCurrency(transaction.totalAmount),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(transaction.transactionDate),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // Show detail button
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        'Tap untuk lihat detail',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(TransactionModel transaction) async {
    final result = await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(
          transaction: transaction,
          product: widget.product,
        ),
      ),
    );

    // If transaction was updated, reload the list
    if (result != null && mounted) {
      await _loadTransactions();
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
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

