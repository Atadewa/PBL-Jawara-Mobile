import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/keluarga_model.dart';

class TambahKeluargaPage extends StatefulWidget {
  const TambahKeluargaPage({super.key});

  @override
  State<TambahKeluargaPage> createState() => _TambahKeluargaPageState();
}

class _TambahKeluargaPageState extends State<TambahKeluargaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomorKKController = TextEditingController();
  final TextEditingController _namaKepalaController = TextEditingController();

  StatusKeluarga _selectedStatus = StatusKeluarga.aktif;
  String? _selectedRumah;

  // Data dummy untuk dropdown rumah
  final List<Map<String, String>> _daftarRumah = [
    {'id': '1', 'nama': 'Blok A / No. 12'},
    {'id': '2', 'nama': 'Blok A / No. 13'},
    {'id': '3', 'nama': 'Blok B / No. 05'},
    {'id': '4', 'nama': 'Blok C / No. 08'},
  ];

  @override
  void dispose() {
    _nomorKKController.dispose();
    _namaKepalaController.dispose();
    super.dispose();
  }

  void _simpanKeluarga() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRumah == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih rumah terlebih dahulu'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      // Implementasi simpan data keluarga
      final keluargaBaru = KeluargaModel(
        nama: _namaKepalaController.text,
        kk: _nomorKKController.text,
        status: _selectedStatus,
        jumlahAnggota: 0,
      );

      Navigator.pop(context, keluargaBaru);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data keluarga berhasil ditambahkan'),
          backgroundColor: Color(0xFF6EE7B7),
        ),
      );
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
                            'Tambah Keluarga',
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
                      'Tambahkan data keluarga baru',
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Icon keluarga
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EE7B7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.people_outline,
                        color: Color(0xFF6EE7B7),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Form fields
                    _buildTextField(
                      label: 'Nomor KK',
                      controller: _nomorKKController,
                      hintText: 'Contoh: 3201010101010001',
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor KK tidak boleh kosong';
                        }
                        if (value.length != 16) {
                          return 'Nomor KK harus 16 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Nama Kepala Keluarga',
                      controller: _namaKepalaController,
                      hintText: 'Masukkan nama kepala keluarga',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama kepala keluarga tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRumahDropdown(),
                    const SizedBox(height: 16),
                    _buildStatusDropdown(),
                    const SizedBox(height: 32),
                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _simpanKeluarga,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6EE7B7),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan Keluarga',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6EE7B7), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRumahDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Rumah',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRumah,
          hint: const Text(
            'Pilih Rumah',
            style: TextStyle(fontSize: 14, color: Color(0xFFA0AEC0)),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6EE7B7), width: 2),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096)),
          isExpanded: true,
          items: _daftarRumah.map((rumah) {
            return DropdownMenuItem(
              value: rumah['id'],
              child: Text(
                rumah['nama']!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRumah = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Keluarga',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<StatusKeluarga>(
          value: _selectedStatus,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6EE7B7), width: 2),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096)),
          isExpanded: true,
          items: StatusKeluarga.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(
                status.label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedStatus = value;
              });
            }
          },
        ),
      ],
    );
  }
}
