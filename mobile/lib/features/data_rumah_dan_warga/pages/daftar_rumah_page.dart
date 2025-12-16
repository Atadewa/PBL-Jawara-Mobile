import 'package:flutter/material.dart';
import '../models/rumah_model.dart';
import '../widgets/rumah_card.dart';
import 'detail_rumah_page.dart';
import 'tambah_rumah_page.dart';

class DaftarRumahPage extends StatefulWidget {
  const DaftarRumahPage({super.key});

  @override
  State<DaftarRumahPage> createState() => _DaftarRumahPageState();
}

class _DaftarRumahPageState extends State<DaftarRumahPage> {
  // Data dummy untuk contoh
  final List<RumahModel> _daftarRumah = [
    RumahModel(
      blok: 'A',
      nomor: '12',
      alamatLengkap: 'Jl. Mawar No. 12, RT 01 / RW 05',
      status: StatusRumah.dihuni,
      jumlahKeluarga: 2,
    ),
    RumahModel(
      blok: 'A',
      nomor: '13',
      alamatLengkap: 'Jl. Mawar No. 13, RT 01 / RW 05',
      status: StatusRumah.kosong,
      jumlahKeluarga: 0,
    ),
    RumahModel(
      blok: 'B',
      nomor: '05',
      alamatLengkap: 'Jl. Melati No. 05, RT 02 / RW 05',
      status: StatusRumah.dalamRenovasi,
      jumlahKeluarga: 0,
    ),
    RumahModel(
      blok: 'C',
      nomor: '08',
      alamatLengkap: 'Jl. Anggrek No. 08, RT 03 / RW 05',
      status: StatusRumah.dihuni,
      jumlahKeluarga: 1,
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
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
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
                            'Daftar Rumah',
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
                      'Kelola data rumah di lingkungan RT/RW',
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
          // List rumah
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 80),
              itemCount: _daftarRumah.length,
              itemBuilder: (context, index) {
                final rumah = _daftarRumah[index];
                return RumahCard(
                  rumah: rumah,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailRumahPage(rumah: rumah),
                      ),
                    );
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahRumahPage()),
          );
        },
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
