import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/layouts/main_layout.dart';
import '../services/broadcast_service.dart';
import '../models/broadcast.dart';

/// Broadcast Form Page - Create or Edit Broadcast
/// Supports image upload (max 1 image)
class BroadcastFormPage extends StatefulWidget {
  final dynamic broadcastId; // null = create, not null = edit

  const BroadcastFormPage({Key? key, this.broadcastId}) : super(key: key);

  @override
  State<BroadcastFormPage> createState() => _BroadcastFormPageState();
}

class _BroadcastFormPageState extends State<BroadcastFormPage> {
  final _formKey = GlobalKey<FormState>();
  final BroadcastService _broadcastService = BroadcastService();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  String _status = 'draft'; // draft, published, archived
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes; // For web platform
  bool _isLoading = false;
  bool _isSaving = false;
  Broadcast? _existingBroadcast;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    if (widget.broadcastId != null) {
      _loadBroadcast();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadBroadcast() async {
    setState(() => _isLoading = true);
    try {
      // Parse broadcastId to int
      int id;
      if (widget.broadcastId is String) {
        id = int.parse(widget.broadcastId);
      } else {
        id = widget.broadcastId as int;
      }

      final broadcast = await _broadcastService.getBroadcastById(id);
      setState(() {
        _existingBroadcast = broadcast;
        _titleController.text = broadcast.title;
        _contentController.text = broadcast.description;
        _status = broadcast.status ?? 'draft';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat broadcast: $e')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        if (kIsWeb) {
          // For web, read bytes immediately
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImage = image;
            _selectedImageBytes = bytes;
          });
        } else {
          setState(() => _selectedImage = image);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'status': _status,
      };

      Broadcast broadcast;

      if (widget.broadcastId == null) {
        // CREATE
        broadcast = await _broadcastService.createBroadcast(data);

        // Upload image if selected
        if (_selectedImage != null) {
          final broadcastId = _getBroadcastId(broadcast.id);
          if (kIsWeb) {
            await _broadcastService.uploadImageBytes(
              broadcastId,
              _selectedImageBytes!,
              _selectedImage!.name,
            );
          } else {
            await _broadcastService.uploadImage(
              broadcastId,
              File(_selectedImage!.path),
            );
          }
        }
      } else {
        // UPDATE
        final id = widget.broadcastId is String
            ? int.parse(widget.broadcastId)
            : widget.broadcastId as int;

        broadcast = await _broadcastService.updateBroadcast(id, data);

        // Upload image if selected (replaces old image)
        if (_selectedImage != null) {
          if (kIsWeb) {
            await _broadcastService.uploadImageBytes(
              id,
              _selectedImageBytes!,
              _selectedImage!.name,
            );
          } else {
            await _broadcastService.uploadImage(id, File(_selectedImage!.path));
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.broadcastId == null
                  ? 'Broadcast berhasil dibuat'
                  : 'Broadcast berhasil diupdate',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan broadcast: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _getBroadcastId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.parse(id);
    throw Exception('Invalid broadcast ID type');
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            widget.broadcastId == null ? 'Tambah Broadcast' : 'Edit Broadcast',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Broadcast *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Judul wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Konten *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 6,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Konten wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'draft',
                            child: Text('Draft'),
                          ),
                          DropdownMenuItem(
                            value: 'published',
                            child: Text('Published'),
                          ),
                          DropdownMenuItem(
                            value: 'archived',
                            child: Text('Archived'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImage != null ||
                          _existingBroadcast?.imageUrl != null)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedImage != null
                              ? kIsWeb
                                    ? Image.memory(
                                        _selectedImageBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(_selectedImage!.path),
                                        fit: BoxFit.cover,
                                      )
                              : _existingBroadcast?.imageUrl != null
                              ? Image.network(
                                  _existingBroadcast!.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox(),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image),
                              label: Text(
                                _selectedImage == null
                                    ? 'Pilih Gambar'
                                    : 'Ganti Gambar',
                              ),
                            ),
                          ),
                          if (_selectedImage != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => setState(() {
                                _selectedImage = null;
                                _selectedImageBytes = null;
                              }),
                              icon: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                widget.broadcastId == null
                                    ? 'Simpan Broadcast'
                                    : 'Update Broadcast',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
