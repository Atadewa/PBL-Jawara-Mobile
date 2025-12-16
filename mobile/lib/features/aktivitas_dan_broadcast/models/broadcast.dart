/// Model untuk data Broadcast/Pengumuman
///
/// Struktur ini merepresentasikan broadcast/pengumuman dari server
/// yang di-fetch melalui BroadcastService
class Broadcast {
  final dynamic id; // Can be String or int from backend
  final String title;
  final String description;
  final DateTime createdAt;
  final String? createdBy;
  final String? imageUrl;
  final String? documentUrl;
  final String? status;
  final int? rw;
  final int? rt;

  Broadcast({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.createdBy,
    this.imageUrl,
    this.documentUrl,
    this.status,
    this.rw,
    this.rt,
  });

  /// Parse JSON response dari API
  ///
  /// Contoh JSON dari API backend:
  /// {
  ///   "id": 1,
  ///   "title": "Pengumuman Iuran Bulanan November",
  ///   "content": "Kepada seluruh warga RT 01/RW 05...",
  ///   "published_at": "2025-11-20T00:00:00Z",
  ///   "image_url": "https://...",
  ///   "status": "published",
  ///   "rw": 5,
  ///   "rt": 1
  /// }
  factory Broadcast.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // Safe int parsing
    int? parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null;
    }

    return Broadcast(
      id: json['id'] ?? '',
      title: json['title'] as String? ?? '',
      description:
          json['content'] as String? ?? json['description'] as String? ?? '',
      createdAt: parseDate(json['published_at'] ?? json['createdAt']),
      createdBy: json['createdBy'] as String?,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      documentUrl: json['document_url'] as String?,
      status: json['status'] as String?,
      rw: parseIntNullable(json['rw']),
      rt: parseIntNullable(json['rt']),
    );
  }

  /// Convert model ke JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': description,
      'published_at': createdAt.toIso8601String(),
      if (createdBy != null) 'createdBy': createdBy,
      if (imageUrl != null) 'image_url': imageUrl,
      if (documentUrl != null) 'document_url': documentUrl,
      if (status != null) 'status': status,
      if (rw != null) 'rw': rw,
      if (rt != null) 'rt': rt,
    };
  }

  /// Create copy with new values
  Broadcast copyWith({
    dynamic id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    String? imageUrl,
    String? documentUrl,
    String? status,
    int? rw,
    int? rt,
  }) {
    return Broadcast(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      imageUrl: imageUrl ?? this.imageUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      status: status ?? this.status,
      rw: rw ?? this.rw,
      rt: rt ?? this.rt,
    );
  }
}
