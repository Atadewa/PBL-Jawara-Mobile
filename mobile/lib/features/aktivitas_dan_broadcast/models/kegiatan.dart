/// Model untuk data Kegiatan
class Kegiatan {
  final String id;
  final String title;
  final String category;
  final String categoryColor;
  final String categoryTextColor;
  final String date;
  final String organizer;
  final String categoryIcon;

  Kegiatan({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.categoryTextColor,
    required this.date,
    required this.organizer,
    required this.categoryIcon,
  });

  /// Parse JSON response dari API
  ///
  /// Contoh JSON dari API:
  /// {
  ///   "id": "kegiatan_001",
  ///   "title": "Gotong Royong Bulanan",
  ///   "category": "Kebersihan",
  ///   "categoryColor": "#DBEA FE",
  ///   "categoryTextColor": "#1347E5",
  ///   "date": "28 November 2025",
  ///   "organizer": "Bapak Ahmad",
  ///   "categoryIcon": "cleaning"
  /// }
  factory Kegiatan.fromJson(Map<String, dynamic> json) {
    return Kegiatan(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryColor: json['categoryColor'] as String? ?? '#FFFFFF',
      categoryTextColor: json['categoryTextColor'] as String? ?? '#000000',
      date: json['date'] as String? ?? '',
      organizer: json['organizer'] as String? ?? '',
      categoryIcon: json['categoryIcon'] as String? ?? '',
    );
  }

  /// Convert model ke JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'categoryColor': categoryColor,
      'categoryTextColor': categoryTextColor,
      'date': date,
      'organizer': organizer,
      'categoryIcon': categoryIcon,
    };
  }

  /// Create copy with new values
  Kegiatan copyWith({
    String? id,
    String? title,
    String? category,
    String? categoryColor,
    String? categoryTextColor,
    String? date,
    String? organizer,
    String? categoryIcon,
  }) {
    return Kegiatan(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryTextColor: categoryTextColor ?? this.categoryTextColor,
      date: date ?? this.date,
      organizer: organizer ?? this.organizer,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }
}
