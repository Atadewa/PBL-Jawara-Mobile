import 'package:flutter/material.dart';
import '../models/rumah_model.dart';

class TambahRumahPage extends StatefulWidget {
  const TambahRumahPage({super.key});

  @override
  State<TambahRumahPage> createState() => _TambahRumahPageState();
}

class _TambahRumahPageState extends State<TambahRumahPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _blokController = TextEditingController();
  final TextEditingController _nomorController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  StatusRumah _selectedStatus = StatusRumah.dihuni;

  @override
  void dispose() {
    _blokController.dispose();
    _nomorController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _simpanRumah() {
    if (_formKey.currentState!.validate()) {
      // Implementasi simpan data rumah
      final rumahBaru = RumahModel(
        blok: _blokController.text,
        nomor: _nomorController.text,
        alamatLengkap: _alamatController.text,
        status: _selectedStatus,
        jumlahKeluarga: 0,
      );

      Navigator.pop(context, rumahBaru);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data rumah berhasil ditambahkan'),
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
                child: Row(
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
                        'Tambahkan data rumah baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                    // Icon rumah
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EE7B7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.home_outlined,
                        color: Color(0xFF6EE7B7),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Form fields
                    _buildTextField(
                      label: 'Blok Rumah',
                      controller: _blokController,
                      hintText: 'Contoh: A',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Blok rumah tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Nomor Rumah',
                      controller: _nomorController,
                      hintText: 'Contoh: 12',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor rumah tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Alamat Lengkap',
                      controller: _alamatController,
                      hintText: 'Masukkan alamat lengkap rumah',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat lengkap tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildStatusDropdown(),
                    const SizedBox(height: 32),
                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _simpanRumah,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6EE7B7),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan Rumah',
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
    int maxLines = 1,
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
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
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

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Rumah',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: DropdownButtonFormField<StatusRumah>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF718096),
            ),
            isExpanded: true,
            items: StatusRumah.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(
                  status.label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                  ),
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
        ),
      ],
    );
  }
}
