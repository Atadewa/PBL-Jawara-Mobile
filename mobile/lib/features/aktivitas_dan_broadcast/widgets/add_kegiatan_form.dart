import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_form_field.dart';
import 'edit_form_image_upload.dart';

typedef OnSaveCallback = Future<void> Function(Map<String, dynamic> formData);

/// Form widget untuk tambah kegiatan baru
/// Berisi semua field input yang diperlukan untuk membuat kegiatan
class AddKegiatanForm extends StatefulWidget {
  final bool isSaving;
  final OnSaveCallback onSave;

  const AddKegiatanForm({
    Key? key,
    required this.isSaving,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddKegiatanForm> createState() => _AddKegiatanFormState();
}

class _AddKegiatanFormState extends State<AddKegiatanForm> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _responsiblePersonController;
  late TextEditingController _dateController;

  String? _selectedCategory;
  List<String> _categories = [
    'Kebersihan',
    'Perayaan',
    'Rapat',
    'Kesehatan',
    'Keagamaan',
    'Olahraga',
    'Pendidikan',
    'Sosial',
  ];

  List<String> _uploadedImages = [];
  final Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// Initialize form controllers dengan nilai default kosong
  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _responsiblePersonController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _responsiblePersonController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Validate form inputs
  bool _validateForm() {
    _fieldErrors.clear();

    if (_titleController.text.isEmpty) {
      _fieldErrors['title'] = 'Nama kegiatan tidak boleh kosong';
    }
    if (_selectedCategory == null) {
      _fieldErrors['category'] = 'Kategori tidak boleh kosong';
    }
    if (_dateController.text.isEmpty) {
      _fieldErrors['date'] = 'Tanggal tidak boleh kosong';
    }
    if (_locationController.text.isEmpty) {
      _fieldErrors['location'] = 'Lokasi tidak boleh kosong';
    }
    if (_responsiblePersonController.text.isEmpty) {
      _fieldErrors['responsible'] = 'Penanggung jawab tidak boleh kosong';
    }

    if (_fieldErrors.isNotEmpty) {
      setState(() {});
      return false;
    }

    return true;
  }

  /// Handle save button pressed
  void _handleSavePressed() {
    if (!_validateForm()) return;

    // Prepare form data
    final formData = {
      'title': _titleController.text,
      'category': _selectedCategory,
      'date': _dateController.text,
      'location': _locationController.text,
      'responsiblePerson': _responsiblePersonController.text,
      'description': _descriptionController.text,
      'documentationImages': _uploadedImages,
    };

    widget.onSave(formData);
  }

  /// Handle image removed dari gallery
  void _handleImageRemoved(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  /// Handle images uploaded
  void _handleImagesUploaded(List<String> newImages) {
    setState(() {
      _uploadedImages.addAll(newImages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        // Nama Kegiatan field
        EditFormField(
          label: 'Nama Kegiatan',
          isRequired: true,
          controller: _titleController,
          hintText: 'Contoh: Gotong Royong Bulanan',
          errorText: _fieldErrors['title'],
        ),

        // Kategori dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              children: [
                const Text(
                  'Kategori',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(color: Color(0xFFFA2B36), fontSize: 16),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1.28,
                    color: _fieldErrors.containsKey('category')
                        ? const Color(0xFFFA2B36)
                        : const Color(0xFFE5E7EB),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('Pilih Kategori'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
            ),
            if (_fieldErrors.containsKey('category'))
              Text(
                _fieldErrors['category']!,
                style: const TextStyle(
                  color: Color(0xFFFA2B36),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),

        // Deskripsi field
        EditFormField(
          label: 'Deskripsi',
          isRequired: false,
          controller: _descriptionController,
          hintText: 'Deskripsi kegiatan...',
          maxLines: 5,
        ),

        // Tanggal field
        EditFormField(
          label: 'Tanggal',
          isRequired: true,
          controller: _dateController,
          hintText: 'Pilih tanggal',
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              _dateController.text = DateFormat(
                'dd MMMM yyyy',
                'id',
              ).format(date);
              setState(() => _fieldErrors.remove('date'));
            }
          },
          prefixIcon: Icons.calendar_today,
          errorText: _fieldErrors['date'],
        ),

        // Lokasi field
        EditFormField(
          label: 'Lokasi',
          isRequired: true,
          controller: _locationController,
          hintText: 'Contoh: Balai RT',
          prefixIcon: Icons.location_on,
          errorText: _fieldErrors['location'],
        ),

        // Penanggung Jawab field
        EditFormField(
          label: 'Penanggung Jawab',
          isRequired: true,
          controller: _responsiblePersonController,
          hintText: 'Nama penanggung jawab',
          prefixIcon: Icons.person,
          errorText: _fieldErrors['responsible'],
        ),

        // Dokumentasi Event section
        EditFormImageUpload(
          kegiatanId: 'new', // For new kegiatan, use 'new' as placeholder
          images: _uploadedImages,
          onImageRemoved: _handleImageRemoved,
          onImagesUploaded: _handleImagesUploaded,
        ),

        const SizedBox(height: 24),

        // Simpan Kegiatan button
        GestureDetector(
          onTap: widget.isSaving ? null : _handleSavePressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: ShapeDecoration(
              color: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: [
                BoxShadow(
                  color: const Color(0x19000000),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0x19000000),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                if (widget.isSaving)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                Text(
                  widget.isSaving ? 'Menyimpan...' : 'Simpan Kegiatan',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
      ],
    );
  }
}
