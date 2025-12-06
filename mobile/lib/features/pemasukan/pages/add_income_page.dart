import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income_model.dart';

class AddIncomePage extends StatefulWidget {
  @override
  _AddIncomePageState createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = 'Donasi';
  DateTime _date = DateTime.now();
  String _amount = '';
  String _description = '';
  // For upload, simulate

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Donasi', 'color': Color(0xFFF3E8FF), 'textColor': Color(0xFF8200DA)},
    {'name': 'Dana Bantuan Pemerintah', 'color': Color(0xFFDBEAFE), 'textColor': Color(0xFF1347E5)},
    {'name': 'Sumbangan Swadaya', 'color': Color(0xFFFFEDD4), 'textColor': Color(0xFFC93400)},
    {'name': 'Hasil Usaha Kampung', 'color': Color(0xFFD0FAE5), 'textColor': Color(0xFF007955)},
    {'name': 'Pendapatan Lainnya', 'color': Colors.grey[200]!, 'textColor': Colors.black},
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _saveIncome() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final categoryMap = _categories.firstWhere((cat) => cat['name'] == _category);
      final income = Income(
        title: _title,
        category: _category,
        amount: 'Rp $_amount',
        date: DateFormat('dd MMMM yyyy').format(_date),
        categoryColor: categoryMap['color'],
        categoryTextColor: categoryMap['textColor'],
      );
      Navigator.pop(context, income);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tambah Pemasukan',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Form (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: inputDecoration('Nama Pemasukan', 'Contoh: Donasi dari Alumni RT'),
                        onSaved: (v) => _title = v!,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: inputDecoration('Kategori'),
                        items: _categories
                            .map<DropdownMenuItem<String>>((c) => DropdownMenuItem(value: c['name'] as String, child: Text(c['name'])))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: DateFormat('dd MMMM yyyy').format(_date)),
                        decoration: inputDecoration('Tanggal').copyWith(
                          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _selectDate),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration('Nominal', '0').copyWith(prefixText: 'Rp '),
                        onSaved: (v) => _amount = v!,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        maxLines: 4,
                        decoration: inputDecoration('Deskripsi', 'Jelaskan detail pemasukan...'),
                        onSaved: (v) => _description = v ?? '',
                      ),
                      const SizedBox(height: 24),

                      // Upload Bukti (Opsional)
                      Text('Upload Bukti (Opsional)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE1E8F0), width: 1.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(color: Color(0x196EE7B7), shape: BoxShape.circle),
                              child: const Icon(Icons.upload_file, size: 32, color: Color(0xFF6EE7B7)),
                            ),
                            const SizedBox(height: 12),
                            const Text('Upload Bukti'),
                            const Text('JPG, PNG (Max. 5MB)', style: TextStyle(color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6EE7B7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _saveIncome,
                          child: const Text('Simpan Pemasukan', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper
  InputDecoration inputDecoration(String label, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE1E8F0), width: 1.7),
      ),
    );
  }
}