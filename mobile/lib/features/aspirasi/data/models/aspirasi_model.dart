/// Model utama untuk aspirasi warga sesuai backend API
class AspirationModel {
  final int id;
  final String title;
  final String description;
  final String? category;
  final AspirationStatus status;
  final int createdByResidentId;
  final int? createdByUserId;
  final int? decidedByUserId;
  final DateTime? decidedAt;
  final String? decisionNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional creator info from backend join
  final String? creatorName;
  final int? creatorRw;
  final int? creatorRt;
  final String? creatorAddress;

  const AspirationModel({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    required this.status,
    required this.createdByResidentId,
    this.createdByUserId,
    this.decidedByUserId,
    this.decidedAt,
    this.decisionNote,
    required this.createdAt,
    required this.updatedAt,
    this.creatorName,
    this.creatorRw,
    this.creatorRt,
    this.creatorAddress,
  });

  AspirationModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    AspirationStatus? status,
    int? createdByResidentId,
    int? createdByUserId,
    int? decidedByUserId,
    DateTime? decidedAt,
    String? decisionNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creatorName,
    int? creatorRw,
    int? creatorRt,
    String? creatorAddress,
  }) {
    return AspirationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdByResidentId: createdByResidentId ?? this.createdByResidentId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      decidedByUserId: decidedByUserId ?? this.decidedByUserId,
      decidedAt: decidedAt ?? this.decidedAt,
      decisionNote: decisionNote ?? this.decisionNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creatorName: creatorName ?? this.creatorName,
      creatorRw: creatorRw ?? this.creatorRw,
      creatorRt: creatorRt ?? this.creatorRt,
      creatorAddress: creatorAddress ?? this.creatorAddress,
    );
  }

  factory AspirationModel.fromJson(Map<String, dynamic> json) {
    // Safe int parsing
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Safe nullable int parsing
    int? parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Parse datetime
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value).toLocal();
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // Parse nullable datetime
    DateTime? parseDateTimeNullable(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value).toLocal();
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Parse creator info from nested object
    String? creatorName;
    int? creatorRw;
    int? creatorRt;
    String? creatorAddress;

    if (json['created_by_resident'] != null) {
      final resident = json['created_by_resident'] as Map<String, dynamic>;
      creatorName = resident['full_name'] as String?;

      if (resident['houses'] != null) {
        final houses = resident['houses'] as Map<String, dynamic>;
        creatorRw = parseIntNullable(houses['rw']);
        creatorRt = parseIntNullable(houses['rt']);
        creatorAddress = houses['address'] as String?;
      }
    }

    return AspirationModel(
      id: parseInt(json['id']),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: json['category'] as String?,
      status: AspirationStatusX.fromString(
        (json['status'] as String?) ?? 'pending',
      ),
      createdByResidentId: parseInt(json['created_by_resident_id']),
      createdByUserId: parseIntNullable(json['created_by_user_id']),
      decidedByUserId: parseIntNullable(json['decided_by_user_id']),
      decidedAt: parseDateTimeNullable(json['decided_at']),
      decisionNote: json['decision_note'] as String?,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      creatorName: creatorName,
      creatorRw: creatorRw,
      creatorRt: creatorRt,
      creatorAddress: creatorAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status.value,
      'created_by_resident_id': createdByResidentId,
      'created_by_user_id': createdByUserId,
      'decided_by_user_id': decidedByUserId,
      'decided_at': decidedAt?.toUtc().toIso8601String(),
      'decision_note': decisionNote,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
}

/// Status aspirasi: pending, in_progress, resolved, rejected
enum AspirationStatus { pending, inProgress, resolved, rejected }

extension AspirationStatusX on AspirationStatus {
  String get label {
    switch (this) {
      case AspirationStatus.pending:
        return 'Pending';
      case AspirationStatus.inProgress:
        return 'Sedang Diproses';
      case AspirationStatus.resolved:
        return 'Diterima';
      case AspirationStatus.rejected:
        return 'Ditolak';
    }
  }

  String get value {
    switch (this) {
      case AspirationStatus.pending:
        return 'pending';
      case AspirationStatus.inProgress:
        return 'in_progress';
      case AspirationStatus.resolved:
        return 'resolved';
      case AspirationStatus.rejected:
        return 'rejected';
    }
  }

  static AspirationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return AspirationStatus.pending;
      case 'in_progress':
        return AspirationStatus.inProgress;
      case 'resolved':
      case 'accepted':
      case 'diterima':
        return AspirationStatus.resolved;
      case 'rejected':
      case 'ditolak':
        return AspirationStatus.rejected;
      default:
        return AspirationStatus.pending;
    }
  }
}

// Legacy compatibility aliases (for existing UI code)
typedef Aspirasi = AspirationModel;
typedef AspirasiStatus = AspirationStatus;

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
