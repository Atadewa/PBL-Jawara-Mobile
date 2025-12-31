import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/layouts/main_layout.dart';
import '../../../core/providers/user_context_provider.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';

/// Event Form Page - Create or Edit Event
/// Supports image upload (max 1 image)
class EventFormPage extends StatefulWidget {
  final int? eventId; // null = create, not null = edit

  const EventFormPage({Key? key, this.eventId}) : super(key: key);

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String _status = 'planned'; // planned, ongoing, completed, cancelled
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes; // For web platform
  bool _isLoading = false;
  bool _isSaving = false;
  EventModel? _existingEvent;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();

    if (widget.eventId != null) {
      _loadEvent();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadEvent() async {
    setState(() => _isLoading = true);
    try {
      final event = await _eventService.getEventById(widget.eventId!);
      setState(() {
        _existingEvent = event;
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _locationController.text = event.location ?? '';
        _startDateTime = event.startDatetime;
        _endDateTime = event.endDatetime;
        _status = event.status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat event: $e')));
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

  Future<void> _selectStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime ?? DateTime.now()),
    );

    if (time != null) {
      setState(() {
        _startDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _selectEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDateTime ?? _startDateTime ?? DateTime.now(),
      firstDate: _startDateTime ?? DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDateTime ?? DateTime.now()),
    );

    if (time != null) {
      setState(() {
        _endDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal mulai wajib diisi')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'start_datetime': _startDateTime!.toIso8601String(),
        'end_datetime': _endDateTime?.toIso8601String(),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'status': _status,
      };

      EventModel event;

      if (widget.eventId == null) {
        // CREATE
        event = await _eventService.createEvent(data);

        // Upload image if selected
        if (_selectedImage != null) {
          if (kIsWeb) {
            await _eventService.uploadImageBytes(
              event.id,
              _selectedImageBytes!,
              _selectedImage!.name,
            );
          } else {
            await _eventService.uploadImage(
              event.id,
              File(_selectedImage!.path),
            );
          }
        }
      } else {
        // UPDATE
        event = await _eventService.updateEvent(widget.eventId!, data);

        // Upload image if selected (replaces old image)
        if (_selectedImage != null) {
          if (kIsWeb) {
            await _eventService.uploadImageBytes(
              widget.eventId!,
              _selectedImageBytes!,
              _selectedImage!.name,
            );
          } else {
            await _eventService.uploadImage(
              widget.eventId!,
              File(_selectedImage!.path),
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.eventId == null
                  ? 'Event berhasil dibuat'
                  : 'Event berhasil diupdate',
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
            content: Text('Gagal menyimpan event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(widget.eventId == null ? 'Tambah Event' : 'Edit Event'),
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
                          labelText: 'Judul Event *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Judul wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Deskripsi wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Tanggal & Waktu Mulai *'),
                        subtitle: Text(
                          _startDateTime == null
                              ? 'Belum dipilih'
                              : '${_startDateTime!.day}/${_startDateTime!.month}/${_startDateTime!.year} ${_startDateTime!.hour.toString().padLeft(2, '0')}:${_startDateTime!.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectStartDateTime,
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Tanggal & Waktu Selesai'),
                        subtitle: Text(
                          _endDateTime == null
                              ? 'Belum dipilih'
                              : '${_endDateTime!.day}/${_endDateTime!.month}/${_endDateTime!.year} ${_endDateTime!.hour.toString().padLeft(2, '0')}:${_endDateTime!.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectEndDateTime,
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
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
                            value: 'planned',
                            child: Text('Direncanakan'),
                          ),
                          DropdownMenuItem(
                            value: 'ongoing',
                            child: Text('Sedang Berlangsung'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Selesai'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text('Dibatalkan'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImage != null ||
                          _existingEvent?.imageUrl != null)
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
                              : _existingEvent?.imageUrl != null
                              ? Image.network(
                                  _existingEvent!.imageUrl!,
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
                                widget.eventId == null
                                    ? 'Simpan Event'
                                    : 'Update Event',
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
