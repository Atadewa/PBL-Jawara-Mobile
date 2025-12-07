/// Model utama untuk aspirasi warga.
///
/// Gunakan model ini untuk semua alur aspirasi agar mudah
/// dipetakan ke response/request API ketika backend sudah siap.
class Aspirasi {
  final String id;
  final String title;
  final String description;
  final AspirasiStatus status;
  final String createdById;
  final String createdBy;
  final DateTime createdAt;

  const Aspirasi({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdById,
    required this.createdBy,
    required this.createdAt,
  });

  Aspirasi copyWith({
    String? id,
    String? title,
    String? description,
    AspirasiStatus? status,
    String? createdById,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Aspirasi(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Aspirasi.fromJson(Map<String, dynamic> json) {
    return Aspirasi(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      status: AspirasiStatusX.fromString((json['status'] as String?) ?? ''),
      createdById: (json['created_by_id'] as String?) ?? '',
      createdBy: (json['created_by'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'created_by_id': createdById,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Status aspirasi sesuai desain existing (Pending, Diterima, Ditolak)
enum AspirasiStatus { pending, diterima, ditolak }

extension AspirasiStatusX on AspirasiStatus {
  String get label {
    switch (this) {
      case AspirasiStatus.pending:
        return 'Pending';
      case AspirasiStatus.diterima:
        return 'Diterima';
      case AspirasiStatus.ditolak:
        return 'Ditolak';
    }
  }

  static AspirasiStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return AspirasiStatus.pending;
      case 'diterima':
      case 'accepted':
        return AspirasiStatus.diterima;
      case 'ditolak':
      case 'rejected':
        return AspirasiStatus.ditolak;
      default:
        return AspirasiStatus.pending;
    }
  }
}

/// Input body untuk membuat/mengubah aspirasi.
class AspirasiInput {
  final String title;
  final String description;
  final String createdById;
  final String createdBy;
  final AspirasiStatus status;

  const AspirasiInput({
    required this.title,
    required this.description,
    required this.createdById,
    required this.createdBy,
    this.status = AspirasiStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'created_by_id': createdById,
      'created_by': createdBy,
      'status': status.name,
    };
  }
}
