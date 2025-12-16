import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/expense_category.dart';
import '../../data/services/expense_service.dart';

/// Halaman Tambah Pengeluaran
class AddPengeluaranPage extends StatefulWidget {
  const AddPengeluaranPage({super.key});

  @override
  State<AddPengeluaranPage> createState() => _AddPengeluaranPageState();
}

class _AddPengeluaranPageState extends State<AddPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ExpenseService _expenseService = ExpenseService();

  ExpenseCategory? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _uploadedFileName;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    // TODO: Implement file picker
    // Untuk saat ini, simulasi upload
    setState(() {
      _uploadedFileName = 'bukti_pengeluaran.jpg';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitur upload file dalam pengembangan'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    // Remove non-digit characters
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    // Format with thousand separator (using dot as separator)
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    return formatted;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(
        _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );

      final expenseData = {
        'title': _nameController.text,
        'category': _selectedCategory!.label,
        'amount': amount,
        'date': _selectedDate.toIso8601String(),
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      };

      await _expenseService.createExpense(expenseData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengeluaran berhasil disimpan'),
            backgroundColor: Color(0xFF34D399),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(14),
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
                    const SizedBox(width: 12),
                    const Text(
                      'Tambah Pengeluaran',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF10B981),
                        ),
                      )
                    : _buildForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Nama Pengeluaran
          _buildFieldLabel('Nama Pengeluaran'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Contoh: Pembelian Alat Kebersihan',
              hintStyle: TextStyle(
                color: const Color(0xFF0A0A0A).withOpacity(0.5),
                fontSize: 16,
                fontFamily: 'Arimo',
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E8F0),
                  width: 1.09,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E8F0),
                  width: 1.09,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.09,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama pengeluaran harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Kategori
          _buildFieldLabel('Kategori'),
          const SizedBox(height: 8),
          DropdownButtonFormField<ExpenseCategory>(
            value: _selectedCategory,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E8F0),
                  width: 1.09,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E8F0),
                  width: 1.09,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.09,
                ),
              ),
            ),
            hint: const Text(
              'Pilih Kategori',
              style: TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 16,
                fontFamily: 'Arimo',
              ),
            ),
            items: ExpenseCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category.label,
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 16,
                    fontFamily: 'Arimo',
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Kategori harus dipilih';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Tanggal Pengeluaran
          _buildFieldLabel('Tanggal Pengeluaran'),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE1E8F0), width: 1.09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nominal
          _buildFieldLabel('Nominal'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: const Color(0xFF0A0A0A).withOpacity(0.5),
                fontSize: 16,
                fontFamily: 'Arimo',
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
                child: Text(
                  'Rp',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              contentPadding: const EdgeInsets.only(
                left: 48,
                right: 16,
                top: 12,
                bottom: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E8F0),
                  width: 1.09,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E8F0),
                  width: 1.09,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.09,
                ),
              ),
            ),
            onChanged: (value) {
              final formatted = _formatCurrency(value);
              _amountController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nominal harus diisi';
              }
              final amount = int.tryParse(
                value.replaceAll(RegExp(r'[^0-9]'), ''),
              );
              if (amount == null || amount <= 0) {
                return 'Nominal tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Deskripsi
          _buildFieldLabel('Deskripsi'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Jelaskan detail pengeluaran...',
              hintStyle: TextStyle(
                color: const Color(0xFF0A0A0A).withOpacity(0.5),
                fontSize: 16,
                fontFamily: 'Arimo',
                height: 1.50,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E8F0),
                  width: 1.09,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE1E8F0),
                  width: 1.09,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.09,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upload Bukti
          _buildFieldLabel('Upload Bukti Pengeluaran'),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickFile,
            child: Container(
              height: 192,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE1E8F0), width: 1.09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _uploadedFileName == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0x1910B981),
                            borderRadius: BorderRadius.circular(36410900),
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            color: Color(0xFF10B981),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Upload Bukti Pengeluaran',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'JPG, PNG (Max. 5MB)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 16,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF34D399),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _uploadedFileName!,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontFamily: 'Arimo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _uploadedFileName = null;
                            });
                          },
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 32),

          // Button Simpan
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0x19000000),
              ),
              child: const Text(
                'Simpan Pengeluaran',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 16,
        fontFamily: 'Arimo',
        fontWeight: FontWeight.w400,
        height: 1.50,
      ),
    );
  }
}
