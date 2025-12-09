import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_colors.dart';

import '../../data/models/aspirasi_model.dart';
import '../../data/services/aspirasi_service.dart';
import '../widgets/aspirasi_status_chip.dart';
import 'create_aspirasi_page.dart';

class AspirasiDetailPage extends StatefulWidget {
  const AspirasiDetailPage({
    super.key,
    required this.aspirasiId,
    required this.service,
    required this.isFromMyAspirasiTab,
  });

  final String aspirasiId;
  final AspirasiService service;
  final bool isFromMyAspirasiTab;

  @override
  State<AspirasiDetailPage> createState() => _AspirasiDetailPageState();
}

class _AspirasiDetailPageState extends State<AspirasiDetailPage> {
  late Future<Aspirasi> _futureDetail;
  bool _isProcessing = false;
  bool _hasChanges = false;
  String? _rejectionReason;

  @override
  void initState() {
    super.initState();
    _futureDetail = widget.service.getAspirasiDetail(widget.aspirasiId);
    _rejectionReason = widget.service.getRejectionReason(widget.aspirasiId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureDetail = widget.service.getAspirasiDetail(widget.aspirasiId);
    });
  }

  Future<void> _updateStatus(AspirasiStatus status) async {
    setState(() => _isProcessing = true);
    try {
      final updated = await widget.service.updateAspirasiStatus(
        widget.aspirasiId,
        status,
        reason: status == AspirasiStatus.ditolak ? _rejectionReason : null,
      );
      if (!mounted) return;
      setState(() {
        _futureDetail = Future.value(updated);
        _hasChanges = true;
        if (status == AspirasiStatus.ditolak) {
          _rejectionReason ??= 'Tidak ada keterangan';
        } else {
          _rejectionReason = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah menjadi ${status.label}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _promptRejectReason() async {
    final controller = TextEditingController(text: _rejectionReason ?? '');
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alasan Penolakan'),
          content: TextField(
            key: const Key('aspirasi_reject_reason_field'),
            controller: controller,
            decoration: const InputDecoration(hintText: 'Masukkan alasan penolakan'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              key: const Key('aspirasi_reject_confirm_button'),
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );

    if (reason != null && reason.isNotEmpty) {
      setState(() => _rejectionReason = reason);
      await _updateStatus(AspirasiStatus.ditolak);
    }
  }

  Future<void> _deleteAspirasi() async {
    setState(() => _isProcessing = true);
    try {
      await widget.service.deleteAspirasi(widget.aspirasiId);
      if (!mounted) return;
      _hasChanges = true;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus aspirasi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _editAspirasi(Aspirasi aspirasi) async {
    final result = await Navigator.push<Aspirasi>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAspirasiPage(
          service: widget.service,
          initialAspirasi: aspirasi,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _futureDetail = Future.value(result);
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMMM yyyy');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.cardBackground,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<Aspirasi>(
              future: _futureDetail,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return ListView(
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error),
                            const SizedBox(height: 8),
                            Text(
                              'Gagal memuat detail aspirasi',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${snapshot.error}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                final aspirasi = snapshot.data!;

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleCard(aspirasi),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Dibuat Oleh',
                                  aspirasi.createdBy,
                                  Icons.person,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  'Tanggal',
                                  formatter.format(aspirasi.createdAt),
                                  Icons.calendar_today_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDescription(aspirasi.description),
                          const SizedBox(height: 24),
                          _buildActionButtons(aspirasi),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 32, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              BackButton(color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Detail Aspirasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Informasi lengkap aspirasi warga',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard(Aspirasi aspirasi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMuted, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              aspirasi.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AspirasiStatusChip(
            status: aspirasi.status,
            compact: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMuted, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMuted, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.notes_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Deskripsi Lengkap',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (_rejectionReason != null) ...[
            const SizedBox(height: 12),
            const Text(
              'Alasan Penolakan',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _rejectionReason!,
              style: const TextStyle(
                color: AppColors.errorDark,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(Aspirasi aspirasi) {
    if (!widget.isFromMyAspirasiTab) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              key: const Key('aspirasi_reject_button'),
              icon: const Icon(Icons.close),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isProcessing ? null : _promptRejectReason,
              label: const Text(
                'Tolak',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              key: const Key('aspirasi_approve_button'),
              icon: const Icon(Icons.check_circle_outline),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isProcessing
                  ? null
                  : () => _updateStatus(AspirasiStatus.diterima),
              label: const Text(
                'Setujui',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
    }

    if (widget.isFromMyAspirasiTab) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              key: const Key('aspirasi_delete_button'),
              icon: const Icon(Icons.delete, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isProcessing ? null : _deleteAspirasi,
              label: const Text(
                'Hapus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              key: const Key('aspirasi_edit_button'),
              icon: const Icon(Icons.edit, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isProcessing ? null : () => _editAspirasi(aspirasi),
              label: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
