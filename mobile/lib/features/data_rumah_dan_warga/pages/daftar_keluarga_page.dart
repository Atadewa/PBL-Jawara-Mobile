import 'package:flutter/material.dart';
import '../models/rumah_model.dart';
import '../models/keluarga_model.dart';
import '../widgets/keluarga_card.dart';

class DaftarKeluargaPage extends StatefulWidget {
  final RumahModel rumah;

  const DaftarKeluargaPage({super.key, required this.rumah});

  @override
  State<DaftarKeluargaPage> createState() => _DaftarKeluargaPageState();
}

class _DaftarKeluargaPageState extends State<DaftarKeluargaPage> {
  // Data dummy untuk contoh
  final List<KeluargaModel> _daftarKeluarga = [
    KeluargaModel(
      nama: 'Budi Santoso',
      kk: '3201010101010001',
      status: StatusKeluarga.aktif,
      jumlahAnggota: 4,
    ),
    KeluargaModel(
      nama: 'Ahmad Hidayat',
      kk: '3201010101010002',
      status: StatusKeluarga.pindahMasuk,
      jumlahAnggota: 3,
    ),
    KeluargaModel(
      nama: 'Siti Nurjanah',
      kk: '3201010101010003',
      status: StatusKeluarga.tidakAktif,
      jumlahAnggota: 2,
    ),
  ];

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
                            'Daftar Keluarga',
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
                    Text(
                      'Keluarga dalam rumah ini',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // List keluarga
          Expanded(
            child: _daftarKeluarga.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data keluarga',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    itemCount: _daftarKeluarga.length,
                    itemBuilder: (context, index) {
                      final keluarga = _daftarKeluarga[index];
                      return KeluargaCard(
                        keluarga: keluarga,
                        onTap: () {
                          // Aksi ketika card diklik
                          // Bisa diarahkan ke detail keluarga
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      // Floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi tambah keluarga
        },
        backgroundColor: const Color(0xFF6EE7B7),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
