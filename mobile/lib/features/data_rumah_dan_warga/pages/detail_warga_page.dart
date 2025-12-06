import 'package:flutter/material.dart';
import '../models/warga_model.dart';
import '../models/keluarga_model.dart';
import 'edit_warga_page.dart';

class DetailWargaPage extends StatelessWidget {
  final Map<String, dynamic> warga;
  final KeluargaModel keluarga;

  const DetailWargaPage({
    super.key,
    required this.warga,
    required this.keluarga,
  });

  Color _getStatusColor() {
    switch (warga['status']) {
      case 'Aktif':
        return const Color(0xFF6EE7B7);
      case 'Pindah':
        return const Color(0xFFFFA726);
      case 'Meninggal':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF6EE7B7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Text(
                            'Detail Warga',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Informasi lengkap data warga',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Card detail warga
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Icon warga
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6EE7B7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF6EE7B7),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Info fields
                        _buildInfoField('Nama Lengkap', warga['nama'] ?? '-'),
                        const SizedBox(height: 16),
                        _buildInfoField('NIK', warga['nik'] ?? '-'),
                        const SizedBox(height: 16),
                        _buildInfoField(
                          'Jenis Kelamin',
                          warga['jenisKelamin'] ?? '-',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoField(
                          'Tempat Lahir',
                          warga['tempatLahir'] ?? '-',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoField(
                          'Tanggal Lahir',
                          warga['tanggalLahir'] ?? '-',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoField('Agama', warga['agama'] ?? '-'),
                        const SizedBox(height: 16),
                        _buildInfoField(
                          'Pendidikan Terakhir',
                          warga['pendidikan'] ?? '-',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoField('Pekerjaan', warga['pekerjaan'] ?? '-'),
                        const SizedBox(height: 16),
                        _buildInfoField(
                          'Hubungan Keluarga',
                          warga['hubungan'] ?? '-',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoFieldWithBadge(
                          'Status',
                          warga['status'] ?? 'Aktif',
                          _getStatusColor(),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoField(
                          'No. Telepon',
                          warga['noTelepon'] ?? '-',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoField('Keluarga', keluarga.nama),
                        const SizedBox(height: 16),
                        _buildInfoField('Nomor KK', keluarga.kk),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tombol Edit Warga
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditWargaPage(warga: warga, keluarga: keluarga),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EE7B7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Edit Data Warga',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoFieldWithBadge(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
