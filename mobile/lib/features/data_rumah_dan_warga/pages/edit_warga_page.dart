import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/warga_model.dart';
import '../models/keluarga_model.dart';

class EditWargaPage extends StatefulWidget {
  final Map<String, dynamic> warga;
  final KeluargaModel keluarga;

  const EditWargaPage({super.key, required this.warga, required this.keluarga});

  @override
  State<EditWargaPage> createState() => _EditWargaPageState();
}

class _EditWargaPageState extends State<EditWargaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nikController;
  late final TextEditingController _namaController;
  late final TextEditingController _tempatLahirController;
  late final TextEditingController _tanggalLahirController;
  late final TextEditingController _pekerjaanController;
  late final TextEditingController _noTeleponController;

  DateTime? _selectedDate;
  late JenisKelamin _selectedJenisKelamin;
  late Agama _selectedAgama;
  late Pendidikan _selectedPendidikan;
  late HubunganKeluarga _selectedHubungan;
  late StatusWarga _selectedStatus;

  @override
  void initState() {
    super.initState();

    // Initialize controllers dengan data existing
    _nikController = TextEditingController(text: widget.warga['nik'] ?? '');
    _namaController = TextEditingController(text: widget.warga['nama'] ?? '');
    _tempatLahirController = TextEditingController(
      text: widget.warga['tempatLahir'] ?? '',
    );
    _tanggalLahirController = TextEditingController(
      text: widget.warga['tanggalLahir'] ?? '',
    );
    _pekerjaanController = TextEditingController(
      text: widget.warga['pekerjaan'] ?? '',
    );
    _noTeleponController = TextEditingController(
      text: widget.warga['noTelepon'] ?? '',
    );

    // Parse tanggal lahir
    try {
      final tanggalLahir = widget.warga['tanggalLahir'];
      if (tanggalLahir != null && tanggalLahir is String) {
        final parts = tanggalLahir.split('-');
        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
    } catch (e) {
      _selectedDate = null;
    }

    // Initialize dropdowns dengan data existing
    _selectedJenisKelamin = _parseJenisKelamin(
      widget.warga['jenisKelamin'] ?? 'Laki-laki',
    );
    _selectedAgama = _parseAgama(widget.warga['agama'] ?? 'Islam');
    _selectedPendidikan = _parsePendidikan(widget.warga['pendidikan'] ?? 'SMA');
    _selectedHubungan = _parseHubunganKeluarga(
      widget.warga['hubungan'] ?? 'Anak',
    );
    _selectedStatus = _parseStatusWarga(widget.warga['status'] ?? 'Aktif');
  }

  // Helper methods untuk parsing enum dari string
  JenisKelamin _parseJenisKelamin(String value) {
    switch (value) {
      case 'Laki-laki':
        return JenisKelamin.lakiLaki;
      case 'Perempuan':
        return JenisKelamin.perempuan;
      default:
        return JenisKelamin.lakiLaki;
    }
  }

  Agama _parseAgama(String value) {
    switch (value) {
      case 'Islam':
        return Agama.islam;
      case 'Kristen':
        return Agama.kristen;
      case 'Katolik':
        return Agama.katolik;
      case 'Hindu':
        return Agama.hindu;
      case 'Buddha':
        return Agama.buddha;
      case 'Konghucu':
        return Agama.konghucu;
      default:
        return Agama.islam;
    }
  }

  Pendidikan _parsePendidikan(String value) {
    switch (value) {
      case 'Tidak Sekolah':
        return Pendidikan.tidakSekolah;
      case 'SD':
        return Pendidikan.sd;
      case 'SMP':
        return Pendidikan.smp;
      case 'SMA':
        return Pendidikan.sma;
      case 'Diploma':
      case 'D3':
        return Pendidikan.diploma;
      case 'Sarjana':
      case 'S1':
        return Pendidikan.sarjana;
      case 'Magister':
      case 'S2':
        return Pendidikan.magister;
      case 'Doktor':
      case 'S3':
        return Pendidikan.doktor;
      default:
        return Pendidikan.sma;
    }
  }

  HubunganKeluarga _parseHubunganKeluarga(String value) {
    switch (value) {
      case 'Kepala Keluarga':
        return HubunganKeluarga.kepalaKeluarga;
      case 'Istri':
        return HubunganKeluarga.istri;
      case 'Anak':
        return HubunganKeluarga.anak;
      case 'Orang Tua':
        return HubunganKeluarga.orangTua;
      case 'Saudara':
        return HubunganKeluarga.saudara;
      default:
        return HubunganKeluarga.anak;
    }
  }

  StatusWarga _parseStatusWarga(String value) {
    switch (value) {
      case 'Aktif':
        return StatusWarga.aktif;
      case 'Pindah':
        return StatusWarga.pindah;
      case 'Meninggal':
        return StatusWarga.meninggal;
      default:
        return StatusWarga.aktif;
    }
  }

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
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement update warga logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data warga berhasil diperbarui'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
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
                    const Expanded(
                      child: Text(
                        'Edit Data Warga',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NIK
                    const Text(
                      'NIK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nikController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Masukkan 16 digit NIK',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NIK wajib diisi';
                        }
                        if (value.length != 16) {
                          return 'NIK harus 16 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nama Lengkap
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama lengkap',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Jenis Kelamin
                    const Text(
                      'Jenis Kelamin',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<JenisKelamin>(
                      value: _selectedJenisKelamin,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      items: JenisKelamin.values.map((jk) {
                        return DropdownMenuItem(
                          value: jk,
                          child: Text(jk.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedJenisKelamin = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tempat Lahir
                    const Text(
                      'Tempat Lahir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tempatLahirController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan tempat lahir',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tempat lahir wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Lahir
                    const Text(
                      'Tanggal Lahir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tanggalLahirController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: InputDecoration(
                        hintText: 'Pilih tanggal lahir',
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF10B981),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal lahir wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Agama
                    const Text(
                      'Agama',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Agama>(
                      value: _selectedAgama,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      items: Agama.values.map((agama) {
                        return DropdownMenuItem(
                          value: agama,
                          child: Text(agama.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAgama = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pendidikan
                    const Text(
                      'Pendidikan Terakhir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Pendidikan>(
                      value: _selectedPendidikan,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      items: Pendidikan.values.map((pendidikan) {
                        return DropdownMenuItem(
                          value: pendidikan,
                          child: Text(pendidikan.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPendidikan = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pekerjaan
                    const Text(
                      'Pekerjaan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pekerjaanController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan pekerjaan',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pekerjaan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Hubungan Keluarga
                    const Text(
                      'Hubungan Keluarga',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<HubunganKeluarga>(
                      value: _selectedHubungan,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      items: HubunganKeluarga.values.map((hubungan) {
                        return DropdownMenuItem(
                          value: hubungan,
                          child: Text(hubungan.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedHubungan = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status
                    const Text(
                      'Status Warga',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<StatusWarga>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      items: StatusWarga.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // No Telepon
                    const Text(
                      'No. Telepon',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noTeleponController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'Masukkan nomor telepon',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'No. telepon wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
}
