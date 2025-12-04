import 'package:flutter/material.dart';
import '../models/rumah_model.dart';

class EditRumahPage extends StatefulWidget {
  final RumahModel rumah;

  const EditRumahPage({super.key, required this.rumah});

  @override
  State<EditRumahPage> createState() => _EditRumahPageState();
}

class _EditRumahPageState extends State<EditRumahPage> {
  late TextEditingController _blokController;
  late TextEditingController _nomorController;
  late TextEditingController _alamatController;
  late StatusRumah _selectedStatus;

  @override
  void initState() {
    super.initState();
    _blokController = TextEditingController(text: widget.rumah.blok);
    _nomorController = TextEditingController(text: widget.rumah.nomor);
    _alamatController = TextEditingController(text: widget.rumah.alamatLengkap);
    _selectedStatus = widget.rumah.status;
  }

  @override
  void dispose() {
    _blokController.dispose();
    _nomorController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _simpanPerubahan() {
    // Implementasi simpan perubahan
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data rumah berhasil diperbarui'),
        backgroundColor: Color(0xFF6EE7B7),
      ),
    );
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
                            'Edit Rumah',
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
                      'Perbarui data rumah',
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
                    hintText: 'Masukkan blok rumah',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Nomor Rumah',
                    controller: _nomorController,
                    hintText: 'Masukkan nomor rumah',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Alamat Lengkap',
                    controller: _alamatController,
                    hintText: 'Masukkan alamat lengkap',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildStatusDropdown(),
                  const SizedBox(height: 32),
                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _simpanPerubahan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EE7B7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
