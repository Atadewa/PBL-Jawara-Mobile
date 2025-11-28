import 'package:flutter/material.dart';
import '../widgets/kategori_card.dart';
import '../widgets/menu_card.dart';
import '../widgets/green_button.dart';

class PemasukanPage extends StatefulWidget {
  const PemasukanPage({super.key});

  @override
  State<PemasukanPage> createState() => _PemasukanPageState();
}

class _PemasukanPageState extends State<PemasukanPage> {
  int selectedTab = 0;

  final List<String> tabs = [
    "Kategori Iuran",
    "Tagihan Iuran",
    "Pemasukan Lain"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _tabs(),
            const SizedBox(height: 10),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildContent(),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ============================= HEADER =============================
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7AD9A8), Color(0xFF4DB8AE)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            "Pemasukan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================= TABS =============================
  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7AD9A8), Color(0xFF4DB8AE)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          tabs.length,
          (index) => GestureDetector(
            onTap: () => setState(() => selectedTab = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    selectedTab == index ? Colors.white : Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color:
                      selectedTab == index ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================= SELECTED CONTENT =============================
  Widget _buildContent() {
    if (selectedTab == 0) {
      return _kategoriIuran();
    } else if (selectedTab == 1) {
      return _tagihanIuran();
    } else {
      return _pemasukanLain();
    }
  }

  // ============================= KATEGORI IURAN =============================
  Widget _kategoriIuran() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const GreenButton(text: "Tambah Kategori Iuran"),
        const SizedBox(height: 16),

        const KategoriCard(
            title: "Iuran Bulanan RT",
            tag: "Bulanan",
            price: "Rp 50.000"),

        const KategoriCard(
            title: "Iuran Kebersihan", tag: "Bulanan", price: "Rp 25.000"),

        const KategoriCard(
            title: "Iuran Agustusan", tag: "Khusus", price: "Rp 100.000"),

        const KategoriCard(
            title: "Iuran Keamanan", tag: "Bulanan", price: "Rp 30.000"),
      ],
    );
  }

  // ============================= TAGIHAN IURAN =============================
  Widget _tagihanIuran() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const MenuCard(
            icon: Icons.add,
            title: "Buat Tagihan Baru",
            subtitle: "Tagih iuran ke seluruh keluarga"),

        const MenuCard(
            icon: Icons.list_alt,
            title: "Daftar Tagihan",
            subtitle: "Lihat dan kelola tagihan iuran"),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFDFF7E6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Info: Setelah membuat tagihan, semua keluarga akan menerima notifikasi dan dapat melakukan pembayaran.",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        )
      ],
    );
  }

  // ============================= PEMASUKAN LAIN =============================
  Widget _pemasukanLain() {
    return const Center(
      child: Text(
        "Halaman Pemasukan Lain\n(bisa kamu isi nanti)",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
