import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../widgets/empty_state_widget.dart';
import 'purchase_detail_page.dart';

/// Halaman riwayat pembelian (untuk buyer)
class MyPurchasesPage extends StatefulWidget {
  const MyPurchasesPage({super.key});

  @override
  State<MyPurchasesPage> createState() => _MyPurchasesPageState();
}

class _MyPurchasesPageState extends State<MyPurchasesPage> {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  // TODO: Ganti dengan user ID yang sebenarnya dari auth
  final String _currentUserId = 'current-user';

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

      final transactions = await _repository.getMyPurchases(_currentUserId);

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
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
    return _buildContent();
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
      return const EmptyStateWidget(
        icon: Icons.shopping_bag_outlined,
        title: 'Belum Ada Pembelian',
        message: 'Riwayat pembelian Anda akan muncul di sini',
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
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                transaction.productImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Transaction Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          transaction.productName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
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

                  // Seller name
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          transaction.sellerName,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Quantity
                  Text(
                    '${transaction.quantity}x produk',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatCurrency(transaction.totalAmount),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _formatShortDate(transaction.transactionDate),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseDetailPage(transaction: transaction),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatShortDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
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

