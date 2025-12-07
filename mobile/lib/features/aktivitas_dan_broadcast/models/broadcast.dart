/// Model untuk data Broadcast/Pengumuman
///
/// Struktur ini merepresentasikan broadcast/pengumuman dari server
/// yang di-fetch melalui BroadcastService
class Broadcast {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? createdBy;
  final String? imageUrl;

  Broadcast({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.createdBy,
    this.imageUrl,
  });

  /// Parse JSON response dari API
  ///
  /// Contoh JSON dari API:
  /// {
  ///   "id": "broadcast_001",
  ///   "title": "Pengumuman Iuran Bulanan November",
  ///   "description": "Kepada seluruh warga RT 01/RW 05...",
  ///   "createdAt": "2025-11-20T00:00:00Z",
  ///   "createdBy": "Ketua RT",
  ///   "imageUrl": "https://..."
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

    return Broadcast(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      createdBy: json['createdBy'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Convert model ke JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      if (createdBy != null) 'createdBy': createdBy,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  /// Create copy with new values
  Broadcast copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    String? imageUrl,
  }) {
    return Broadcast(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
