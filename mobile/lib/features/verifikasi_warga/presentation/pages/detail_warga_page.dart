import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/warga_verification_item.dart';
import '../../data/services/warga_verification_service.dart';
import '../widgets/approval_confirmation_dialog.dart';
import '../widgets/rejection_dialog.dart';

class DetailWargaPage extends StatefulWidget {
  final WargaVerificationItem warga;

  const DetailWargaPage({super.key, required this.warga});

  @override
  State<DetailWargaPage> createState() => _DetailWargaPageState();
}

class _DetailWargaPageState extends State<DetailWargaPage> {
  final WargaVerificationService _service = WargaVerificationService();
  bool _isApproving = false;
  bool _isRejecting = false;

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMMM yyyy').format(date);
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showApprovalConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApprovalConfirmationDialog(
        wargaName: widget.warga.nama,
        onApprove: _approveWarga,
      ),
    );
  }

  Future<void> _approveWarga() async {
    setState(() => _isApproving = true);
    try {
      final success = await _service.approveVerification(widget.warga.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.warga.nama} berhasil disetujui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isApproving = false);
      }
    }
  }

  void _showRejectionConfirmation() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RejectionDialog(
        onReject: _rejectWargaWithReason,
      ),
    );
  }

  Future<void> _rejectWargaWithReason(String reason) async {
    setState(() => _isRejecting = true);
    try {
      final success = await _service.rejectVerification(
        widget.warga.id,
        reason,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.warga.nama} ditolak'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isRejecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, 0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    const Expanded(
                      child: Text(
                        'Detail Warga Pending',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
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
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 10,
                        offset: Offset(0, 8),
                        spreadRadius: -6,
                      ),
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 25,
                        offset: Offset(0, 20),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Profile Card Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildProfileCard(),
                      ),
                      const SizedBox(height: 24),
                      // Info Sections
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildInfoSection('Informasi Dasar', [
                              _InfoRow(
                                'Tanggal Lahir',
                                '${_formatDate(widget.warga.tanggalLahir)} (${_calculateAge(widget.warga.tanggalLahir)} tahun)',
                              ),
                              _InfoRow(
                                'Jenis Kelamin',
                                widget.warga.jenisKelamin ?? '-',
                              ),
                              _InfoRow('Agama', widget.warga.agama ?? '-'),
                              _InfoRow(
                                'Pendidikan',
                                widget.warga.pendidikan ?? '-',
                              ),
                              _InfoRow(
                                'Pekerjaan',
                                widget.warga.pekerjaan ?? '-',
                              ),
                            ]),
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              'Informasi Kontak',
                              [
                                _InfoRow(
                                  'Nomor Telepon',
                                  widget.warga.nomorTelepon ?? '-',
                                ),
                              ],
                              icon: Icons.phone,
                              iconColor: const Color(0xFF6EE7B7),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              'Informasi Keluarga',
                              [
                                _InfoRow(
                                  'Kepala Keluarga',
                                  widget.warga.kepalaKeluarga ?? '-',
                                ),
                                _InfoRow(
                                  'Keluarga',
                                  widget.warga.keluarga ?? '-',
                                ),
                              ],
                              icon: Icons.family_restroom,
                              iconColor: const Color(0xFF6EE7B7),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              'Informasi Rumah',
                              [_InfoRow('Alamat', widget.warga.alamat ?? '-')],
                              icon: Icons.home,
                              iconColor: const Color(0xFF6EE7B7),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              'Informasi Tambahan',
                              [
                                _InfoRow(
                                  'Diajukan Oleh',
                                  widget.warga.diajukanOleh,
                                ),
                              ],
                              icon: Icons.info,
                              iconColor: const Color(0xFF6EE7B7),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          children: [
                            // Approve Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isApproving
                                    ? null
                                    : _showApprovalConfirmation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6EE7B7),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  disabledBackgroundColor: const Color(
                                    0xFF6EE7B7,
                                  ).withOpacity(0.5),
                                ),
                                child: _isApproving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Setujui Warga',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Reject Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isRejecting
                                    ? null
                                    : _showRejectionConfirmation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFEE2E2),
                                  foregroundColor: const Color(0xFFEF4444),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  disabledBackgroundColor: const Color(
                                    0xFFFEE2E2,
                                  ).withOpacity(0.5),
                                ),
                                child: _isRejecting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFFEF4444),
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Tolak Warga',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                        ),
                                      ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0x196EE7B7),
              borderRadius: BorderRadius.circular(48),
            ),
            child: const Icon(Icons.person, color: Color(0xFF6EE7B7), size: 48),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            widget.warga.nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 8),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.warga.status.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.warga.status.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.warga.status.textColor,
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // NIK
          Text(
            'NIK: ${widget.warga.nik}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    List<_InfoRow> rows, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with optional icon
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? const Color(0xFF0F172A),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info rows
          ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < rows.length - 1 ? 12 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}
