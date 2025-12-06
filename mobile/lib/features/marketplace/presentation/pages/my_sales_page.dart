import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../widgets/empty_state_widget.dart';

/// Halaman riwayat penjualan (untuk seller)
class MySalesPage extends StatefulWidget {
  const MySalesPage({super.key});

  @override
  State<MySalesPage> createState() => _MySalesPageState();
}

class _MySalesPageState extends State<MySalesPage> {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  // TODO: Ganti dengan user ID yang sebenarnya dari auth
  final String _currentUserId = 'user-1';

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

      final transactions = await _repository.getMySales(_currentUserId);

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
        icon: Icons.receipt_long_outlined,
        title: 'Belum Ada Penjualan',
        message: 'Penjualan Anda akan muncul di sini',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: AppColors.success,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildTransactionCard(_transactions[index]);
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.id,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildStatusBadge(transaction.status),
                  ],
                ),
                const SizedBox(height: 12),

                // Product Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        transaction.productImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.productName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${transaction.quantity} pcs × ${_formatCurrency(transaction.price)}',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Divider(height: 1, color: AppColors.borderMuted),
                const SizedBox(height: 12),

                // Buyer Info
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pembeli:',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.buyerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(transaction.transactionDate),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Penjualan',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                    ),
                    Text(
                      _formatCurrency(transaction.totalAmount),
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons (for pending/processing)
          if (transaction.status == TransactionStatus.pending ||
              transaction.status == TransactionStatus.processing)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderMuted, width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (transaction.status == TransactionStatus.pending) ...[
                    Expanded(
                      child: InkWell(
                        onTap: () => _handleUpdateStatus(
                          transaction,
                          TransactionStatus.processing,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Terima Pesanan',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.borderMuted,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _handleUpdateStatus(
                          transaction,
                          TransactionStatus.cancelled,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel,
                                size: 18,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tolak',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else if (transaction.status == TransactionStatus.processing)
                    Expanded(
                      child: InkWell(
                        onTap: () => _handleUpdateStatus(
                          transaction,
                          TransactionStatus.completed,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Selesaikan Pesanan',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleUpdateStatus(
    TransactionModel transaction,
    TransactionStatus newStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String message = '';

        switch (newStatus) {
          case TransactionStatus.processing:
            title = 'Terima Pesanan';
            message = 'Apakah Anda yakin ingin menerima pesanan ini?';
            break;
          case TransactionStatus.completed:
            title = 'Selesaikan Pesanan';
            message = 'Apakah pesanan sudah selesai dan diterima pembeli?';
            break;
          case TransactionStatus.cancelled:
            title = 'Tolak Pesanan';
            message = 'Apakah Anda yakin ingin menolak pesanan ini?';
            break;
          default:
            break;
        }

        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _repository.updateTransactionStatus(
                    transaction.id,
                    newStatus,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Status pesanan berhasil diupdate'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadTransactions();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengupdate status: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == TransactionStatus.cancelled
                    ? AppColors.error
                    : AppColors.success,
                foregroundColor: AppColors.background,
              ),
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
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

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(date);
  }
}

