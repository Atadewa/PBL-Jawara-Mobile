import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/theme/app_colors.dart';

import '../../data/models/aspirasi_model.dart';
import '../providers/aspiration_provider.dart';

class CreateAspirasiPage extends StatefulWidget {
  const CreateAspirasiPage({super.key, this.initialAspiration});

  final AspirationModel? initialAspiration;

  bool get isEditing => initialAspiration != null;

  @override
  State<CreateAspirasiPage> createState() => _CreateAspirasiPageState();
}

class _CreateAspirasiPageState extends State<CreateAspirasiPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialAspiration?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialAspiration?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.initialAspiration?.category ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<AspirationProvider>();

    try {
      if (widget.isEditing) {
        await provider.updateMyAspiration(
          id: widget.initialAspiration!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
        );
      } else {
        await provider.createAspiration(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      // Handle specific errors
      String errorMessage = 'Gagal menyimpan aspirasi';
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        errorMessage = 'Tidak punya akses untuk melakukan aksi ini';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Sesi Anda telah berakhir, silakan login kembali';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$errorMessage: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowMedium,
                      blurRadius: 10,
                      offset: Offset(0, 8),
                      spreadRadius: -6,
                    ),
                    BoxShadow(
                      color: AppColors.shadowMedium,
                      blurRadius: 25,
                      offset: Offset(0, 20),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          label: 'Judul Aspirasi',
                          hint: 'Masukkan judul aspirasi',
                          controller: _titleController,
                          fieldKey: const Key('aspirasi_form_title'),
                        ),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Kategori (Opsional)',
                          hint: 'Misalnya: Infrastruktur, Kebersihan, dll',
                          controller: _categoryController,
                          fieldKey: const Key('aspirasi_form_category'),
                        ),
                        const SizedBox(height: 24),
                        _buildSubmitButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final title = widget.isEditing ? 'Edit Aspirasi' : 'Tambah Aspirasi';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 32, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sampaikan aspirasi Anda untuk lingkungan RT/RW',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    Key? fieldKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: fieldKey,
          controller: controller,
          validator: (value) {
            // Category is optional
            if (label.contains('Opsional')) return null;
            return (value == null || value.trim().isEmpty)
                ? 'Harus diisi'
                : null;
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.borderMuted,
                width: 1.1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.borderMuted,
                width: 1.1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('aspirasi_form_description'),
          controller: _descriptionController,
          minLines: 5,
          maxLines: 6,
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Harus diisi' : null,
          decoration: InputDecoration(
            hintText: 'Jelaskan aspirasi Anda secara detail',
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.borderMuted,
                width: 1.1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.borderMuted,
                width: 1.1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButtons() {
    final saveLabel = widget.isEditing
        ? 'Perbarui Aspirasi'
        : 'Simpan Aspirasi';
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const Key('aspirasi_form_save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isSaving ? null : _save,
            child: Text(
              saveLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.borderMuted, width: 1.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isSaving ? null : _resetForm,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
