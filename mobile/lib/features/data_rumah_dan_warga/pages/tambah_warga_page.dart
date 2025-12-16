import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/warga_model.dart';
import '../models/keluarga_model.dart';

class TambahWargaPage extends StatefulWidget {
  final KeluargaModel keluarga;

  const TambahWargaPage({super.key, required this.keluarga});

  @override
  State<TambahWargaPage> createState() => _TambahWargaPageState();
}

class _TambahWargaPageState extends State<TambahWargaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();

  DateTime? _selectedDate;
  JenisKelamin _selectedJenisKelamin = JenisKelamin.lakiLaki;
  Agama _selectedAgama = Agama.islam;
  Pendidikan _selectedPendidikan = Pendidikan.sma;
  HubunganKeluarga _selectedHubungan = HubunganKeluarga.anak;
  StatusWarga _selectedStatus = StatusWarga.aktif;

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _pekerjaanController.dispose();
    _noTeleponController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D3748),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _simpanWarga() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih tanggal lahir terlebih dahulu'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      // Implementasi simpan data warga
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data warga berhasil ditambahkan'),
          backgroundColor: Color(0xFF10B981),
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
                            'Tambah Warga',
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
                      'Tambahkan data warga baru',
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
                    _buildTextField(
                      label: 'NIK',
                      controller: _nikController,
                      hintText: 'Masukkan 16 digit NIK',
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NIK tidak boleh kosong';
                        }
                        if (value.length != 16) {
                          return 'NIK harus 16 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Nama Lengkap',
                      controller: _namaController,
                      hintText: 'Masukkan nama lengkap',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<JenisKelamin>(
                      label: 'Jenis Kelamin',
                      value: _selectedJenisKelamin,
                      items: JenisKelamin.values,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedJenisKelamin = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Tempat Lahir',
                      controller: _tempatLahirController,
                      hintText: 'Masukkan tempat lahir',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tempat lahir tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(),
                    const SizedBox(height: 16),
                    _buildDropdown<Agama>(
                      label: 'Agama',
                      value: _selectedAgama,
                      items: Agama.values,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAgama = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<Pendidikan>(
                      label: 'Pendidikan',
                      value: _selectedPendidikan,
                      items: Pendidikan.values,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPendidikan = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Pekerjaan',
                      controller: _pekerjaanController,
                      hintText: 'Masukkan pekerjaan',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pekerjaan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<HubunganKeluarga>(
                      label: 'Hubungan Keluarga',
                      value: _selectedHubungan,
                      items: HubunganKeluarga.values,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedHubungan = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<StatusWarga>(
                      label: 'Status',
                      value: _selectedStatus,
                      items: StatusWarga.values,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'No. Telepon (Opsional)',
                      controller: _noTeleponController,
                      hintText: 'Masukkan nomor telepon',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),
                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _simpanWarga,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan Warga',
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
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Lahir',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tanggalLahirController,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            hintText: 'Pilih tanggal lahir',
            hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Color(0xFF10B981),
            ),
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
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T extends Enum>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
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
        DropdownButtonFormField<T>(
          value: value,
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
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096)),
          isExpanded: true,
          items: items.map((item) {
            String itemLabel = '';
            if (item is JenisKelamin) {
              itemLabel = (item as JenisKelamin).label;
            } else if (item is Agama) {
              itemLabel = (item as Agama).label;
            } else if (item is Pendidikan) {
              itemLabel = (item as Pendidikan).label;
            } else if (item is HubunganKeluarga) {
              itemLabel = (item as HubunganKeluarga).label;
            } else if (item is StatusWarga) {
              itemLabel = (item as StatusWarga).label;
            }

            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
