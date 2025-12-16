/// Model for Event/Kegiatan
class EventModel {
  final int id;
  final int rw;
  final int? rt;
  final String title;
  final String description;
  final DateTime startDatetime;
  final DateTime? endDatetime;
  final String? location;
  final String status;
  final String? imageUrl;

  EventModel({
    required this.id,
    required this.rw,
    this.rt,
    required this.title,
    required this.description,
    required this.startDatetime,
    this.endDatetime,
    this.location,
    required this.status,
    this.imageUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue).toLocal();
        } catch (e) {
          print('[EventModel] Error parsing date: $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // Safe int parsing
    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    int? parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null;
    }

    return EventModel(
      id: parseInt(json['id']),
      rw: parseInt(json['rw']),
      rt: parseIntNullable(json['rt']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      startDatetime: parseDate(json['start_datetime']),
      endDatetime: json['end_datetime'] != null
          ? parseDate(json['end_datetime'])
          : null,
      location: json['location']?.toString(),
      status: json['status']?.toString() ?? 'planned',
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rw': rw,
      'rt': rt,
      'title': title,
      'description': description,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime?.toIso8601String(),
      'location': location,
      'status': status,
      'image_url': imageUrl,
    };
  }

  /// Format start datetime for display
  String get formattedDate {
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

    return '${startDatetime.day} ${months[startDatetime.month - 1]} ${startDatetime.year}';
  }

  /// Format time for display
  String get formattedTime {
    final hour = startDatetime.hour.toString().padLeft(2, '0');
    final minute = startDatetime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get status label in Indonesian
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'published':
        return 'Dipublikasikan';
      case 'draft':
        return 'Draft';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Get full datetime formatted
  String get fullDateTime {
    return '$formattedDate, $formattedTime';
  }

  /// Get location or default text
  String get locationText {
    return location ?? 'Lokasi belum ditentukan';
  }
}
