import 'package:flutter/material.dart';
import 'dart:io';

// TODO: Uncomment when image_picker is added to pubspec.yaml
// import 'package:image_picker/image_picker.dart';

// TODO: Uncomment when file_picker is added to pubspec.yaml
// import 'package:file_picker/file_picker.dart';

/// Halaman Tambah Broadcast (Create)
/// Memungkinkan user untuk membuat broadcast baru
/// dengan form validation dan error handling yang proper
class AddBroadcastPage extends StatefulWidget {
  const AddBroadcastPage({Key? key}) : super(key: key);

  @override
  State<AddBroadcastPage> createState() => _AddBroadcastPageState();
}

class _AddBroadcastPageState extends State<AddBroadcastPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;

  // State variables
  bool _isLoading = false;
  String? _selectedImagePath;
  String? _selectedDocumentPath;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Handle image selection (upload dari galeri/penyimpanan)
  /// TODO: Integrate dengan image picker library
  /// Step 1: Add image_picker to pubspec.yaml: image_picker: ^1.0.0
  /// Step 2: Uncomment import at top of file
  /// Step 3: Uncomment production code below
  /// Step 4: Compress image sebelum upload
  /// Step 5: Store file path untuk upload nanti
  Future<void> _onSelectImage() async {
    try {
      // TODO: Uncomment production code when image_picker is added
      // import 'package:image_picker/image_picker.dart' at top
      // final pickedFile = await ImagePicker().pickImage(
      //   source: ImageSource.gallery,
      //   imageQuality: 80,
      // );
      // if (pickedFile != null) {
      //   setState(() {
      //     _selectedImagePath = pickedFile.path;
      //   });
      // }

      // DUMMY - Remove when production
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Upload foto dari galeri/penyimpanan (install image_picker package)',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar: $e');
    }
  }

  /// Handle image removal
  void _onRemoveImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  /// Show date picker dialog
  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  /// Format date to display format
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Handle document selection
  /// TODO: Integrate dengan file picker library
  /// Step 1: Add file_picker to pubspec.yaml: file_picker: ^5.3.0
  /// Step 2: Uncomment import at top of file
  /// Step 3: Uncomment production code below
  /// Step 4: Validate file size (max 10MB recommended)
  /// Step 5: Store file path untuk upload nanti
  Future<void> _onSelectDocument() async {
    try {
      // TODO: Implement file picker when file_picker is added
      // import 'package:file_picker/file_picker.dart' at top
      // final pickedFile = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['pdf'],
      // );
      // if (pickedFile != null) {
      //   final file = pickedFile.files.single;
      //   // Validate file size (max 10MB)
      //   if (file.size > 10 * 1024 * 1024) {
      //     _showErrorSnackBar('File terlalu besar (max 10MB)');
      //     return;
      //   }
      //   setState(() {
      //     _selectedDocumentPath = file.path;
      //   });
      // }

      // DUMMY - Remove when production
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'File picker - coming soon (install file_picker package)',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Gagal memilih dokumen: $e');
    }
  }

  /// Handle document removal
  void _onRemoveDocument() {
    setState(() {
      _selectedDocumentPath = null;
    });
  }

  /// Submit form untuk create broadcast
  /// TODO: Implement API call untuk create broadcast
  /// Step 1: Validate form
  /// Step 2: Prepare multipart request (image + document)
  /// Step 3: Send POST request ke /broadcasts
  /// Step 4: Handle response dan navigate back
  /// Step 5: Handle error dengan proper error message
  Future<void> _onSaveBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // TODO: Implement actual API call
      // 1. Create FormData dengan fields
      // 2. Add image jika ada
      // 3. Add document jika ada
      // 4. Send POST request ke /broadcasts
      // 5. Get response dan handle success/error
      //
      // Example with Dio:
      // final dio = Dio();
      // final formData = FormData.fromMap({
      //   'title': _titleController.text,
      //   'description': _descriptionController.text,
      //   if (_selectedImagePath != null)
      //     'image': await MultipartFile.fromFile(_selectedImagePath!),
      //   if (_selectedDocumentPath != null)
      //     'document': await MultipartFile.fromFile(_selectedDocumentPath!),
      // });
      // final response = await dio.post('/broadcasts', data: formData);
      // return Broadcast.fromJson(response.data['data']);

      // Dummy: Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Success - Go back to broadcast page
      Navigator.pop(context, true);
      _showSuccessSnackBar('Broadcast berhasil dibuat');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal membuat broadcast: $e');
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header dengan gradient
              _buildHeader(),
              // Content form
              Padding(padding: const EdgeInsets.all(16), child: _buildForm()),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Tambah Broadcast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build form
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Title field
          _buildTitleField(),
          const SizedBox(height: 20),
          // Date field
          _buildDateField(),
          const SizedBox(height: 20),
          // Description field
          _buildDescriptionField(),
          const SizedBox(height: 20),
          // Image section
          _buildImageSection(),
          const SizedBox(height: 20),
          // Document section
          _buildDocumentSection(),
          const SizedBox(height: 24),
          // Save button
          _buildSaveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Build title field
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Judul Broadcast',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Color(0xFFFA2B36), fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Contoh: Pengumuman Iuran Bulanan',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Judul broadcast tidak boleh kosong';
            }
            if (value.length < 3) {
              return 'Judul minimal 3 karakter';
            }
            if (value.length > 100) {
              return 'Judul maksimal 100 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build date field with picker
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tanggal',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Color(0xFFFA2B36), fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _showDatePicker,
          decoration: InputDecoration(
            hintText: 'Pilih tanggal',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tanggal tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build description field
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Isi Broadcast',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Color(0xFFFA2B36), fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Tulis isi broadcast di sini...',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Isi broadcast tidak boleh kosong';
            }
            if (value.length < 10) {
              return 'Isi broadcast minimal 10 karakter';
            }
            if (value.length > 5000) {
              return 'Isi broadcast maksimal 5000 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build image section
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _onSelectImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0D5DB), width: 1),
            ),
            child: _selectedImagePath != null
                ? Stack(
                    children: [
                      // Image display
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(_selectedImagePath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Remove button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _onRemoveImage,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFB2C36),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '×',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Upload Foto',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Build document section
  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dokumen',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _onSelectDocument,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0D5DB), width: 1),
            ),
            child: _selectedDocumentPath != null
                ? Row(
                    children: [
                      Container(
                        width: 60,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: Color(0xFF10B981),
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedDocumentPath!.split('/').last,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Dokumen terpilih',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: _onRemoveDocument,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '×',
                                style: TextStyle(
                                  color: Color(0xFFFA2B36),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 24,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Upload Dokumen',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSaveBroadcast,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Simpan Broadcast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
