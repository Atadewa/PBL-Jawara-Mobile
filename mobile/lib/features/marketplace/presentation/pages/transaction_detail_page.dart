import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

/// Halaman Detail Transaksi Pembeli untuk Seller
class TransactionDetailPage extends StatefulWidget {
  final TransactionModel transaction;
  final ProductModel product;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
    required this.product,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final TransactionRepository _repository = TransactionRepository();
  late TransactionModel _transaction;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _handleApprove() async {
    final confirmed = await _showConfirmDialog(
      'Setujui Transaksi',
      'Apakah Anda yakin ingin menyetujui transaksi ini?',
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final updatedTransaction = await _repository.updateTransactionStatus(
        _transaction.id,
        TransactionStatus.processing,
      );

      if (!mounted) return;

      setState(() {
        _transaction = updatedTransaction;
        _isProcessing = false;
      });

      _showSuccessSnackBar('Transaksi berhasil disetujui');
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);
      _showErrorSnackBar('Gagal menyetujui transaksi: $e');
    }
  }

  Future<void> _handleReject() async {
    final confirmed = await _showConfirmDialog(
      'Tolak Transaksi',
      'Apakah Anda yakin ingin menolak transaksi ini? Tindakan ini tidak dapat dibatalkan.',
    );

    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final updatedTransaction = await _repository.updateTransactionStatus(
        _transaction.id,
        TransactionStatus.cancelled,
      );

      if (!mounted) return;

      setState(() {
        _transaction = updatedTransaction;
        _isProcessing = false;
      });

      _showSuccessSnackBar('Transaksi berhasil ditolak');
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);
      _showErrorSnackBar('Gagal menolak transaksi: $e');
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
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
              child: Row(
                children: [
                  // Back button
                  InkWell(
                    onTap: () => Navigator.pop(context, _transaction),
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
                      'Detail Transaksi Pembeli',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi Pembeli
                  _buildInfoSection('Informasi Pembeli', [_buildBuyerInfo()]),
                  const SizedBox(height: 16),

                  // Informasi Produk
                  _buildInfoSection('Informasi Produk', [
                    _buildDetailRow('Produk', widget.product.name),
                    _buildDetailRow(
                      'Harga Satuan',
                      _formatCurrency(widget.product.price),
                    ),
                    _buildDetailRow('Jumlah', '${_transaction.quantity}x'),
                    const Divider(height: 20),
                    _buildDetailRow(
                      'Total',
                      _formatCurrency(_transaction.totalAmount),
                      isTotal: true,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Status Transaksi
                  _buildInfoSection('Status Transaksi', [
                    _buildDetailRow('Kode Transaksi', _transaction.id),
                    _buildDetailRow(
                      'Tanggal',
                      _formatDate(_transaction.transactionDate),
                    ),
                    _buildStatusRow('Status', _transaction.status),
                    if (_transaction.notes != null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Catatan',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _transaction.notes!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 24),

                  // Bukti Pembayaran
                  _buildPaymentProof(),
                  const SizedBox(height: 24),

                  // Action Buttons (only for pending status)
                  if (_transaction.status == TransactionStatus.pending)
                    _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBuyerInfo() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1000),
          ),
          child: Center(
            child: Text(
              _transaction.buyerName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _transaction.buyerName,
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
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isTotal
                    ? AppColors.success
                    : AppColors.textPrimary,
                fontSize: isTotal ? 16 : 12,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, TransactionStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.label,
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProof() {
    final paymentProof = _transaction.paymentProof;
    final paymentBank = _transaction.paymentBank ?? '-';
    final paymentNotes = _transaction.notes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.borderLight),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bukti Pembayaran',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (paymentProof != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                paymentProof,
                width: double.infinity,
                height: 224,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 224,
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 224,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Bukti pembayaran belum diunggah',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          _buildDetailRow('Nama Pengirim', _transaction.buyerName),
          if (paymentNotes != null && paymentNotes.isNotEmpty)
            _buildDetailRow('Catatan', paymentNotes),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _isProcessing ? null : _handleReject,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.error),
                      ),
                    )
                  : const Text(
                      'Tolak',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.background),
                      ),
                    )
                  : const Text(
                      'Setujui',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
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

