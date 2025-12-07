/// Model untuk detail kegiatan dengan semua informasi lengkap
///
/// Digunakan pada halaman detail kegiatan untuk menampilkan
/// informasi lengkap tentang suatu kegiatan termasuk deskripsi,
/// dokumentasi, dan aksi yang tersedia

class KegiatanDetail {
  final String id;
  final String title;
  final String category;
  final String categoryColor;
  final String categoryTextColor;
  final DateTime date;
  final String location;
  final String responsiblePerson;
  final String createdBy;
  final String description;
  final List<String> documentationImages;
  final DateTime createdAt;
  final DateTime? updatedAt;

  KegiatanDetail({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.categoryTextColor,
    required this.date,
    required this.location,
    required this.responsiblePerson,
    required this.createdBy,
    required this.description,
    required this.documentationImages,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert JSON response to KegiatanDetail model
  /// API Response format:
  /// {
  ///   "id": "kegiatan_123",
  ///   "title": "Gotong Royong Bulanan",
  ///   "category": "Kebersihan",
  ///   "categoryColor": "#DBEAFE",
  ///   "categoryTextColor": "#1347E5",
  ///   "date": "2025-11-28T09:00:00Z",
  ///   "location": "Balai RT",
  ///   "responsiblePerson": "Bapak Ahmad",
  ///   "createdBy": "Admin RT",
  ///   "description": "Kegiatan gotong royong rutin...",
  ///   "documentationImages": ["url1", "url2", "url3"],
  ///   "createdAt": "2025-11-15T10:00:00Z",
  ///   "updatedAt": "2025-11-20T14:30:00Z"
  /// }
  factory KegiatanDetail.fromJson(Map<String, dynamic> json) {
    return KegiatanDetail(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      categoryColor: json['categoryColor'] ?? '#DBEAFE',
      categoryTextColor: json['categoryTextColor'] ?? '#1347E5',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      location: json['location'] ?? '',
      responsiblePerson: json['responsiblePerson'] ?? '',
      createdBy: json['createdBy'] ?? '',
      description: json['description'] ?? '',
      documentationImages: List<String>.from(json['documentationImages'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert KegiatanDetail to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'categoryColor': categoryColor,
      'categoryTextColor': categoryTextColor,
      'date': date.toIso8601String(),
      'location': location,
      'responsiblePerson': responsiblePerson,
      'createdBy': createdBy,
      'description': description,
      'documentationImages': documentationImages,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Format tanggal untuk tampilan
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
