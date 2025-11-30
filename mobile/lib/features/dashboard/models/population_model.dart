/// Model untuk Population Dashboard

/// Summary data untuk populasi
class PopulationSummary {
  final String totalFamilies; // Total keluarga
  final String totalResidents; // Total penduduk

  PopulationSummary({
    required this.totalFamilies,
    required this.totalResidents,
  });

  factory PopulationSummary.fromJson(Map<String, dynamic> json) {
    return PopulationSummary(
      totalFamilies: json['totalFamilies']?.toString() ?? '0',
      totalResidents: json['totalResidents']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {'totalFamilies': totalFamilies, 'totalResidents': totalResidents};
  }
}

/// Kategori populasi (Status Penduduk, Jenis Kelamin, dll)
class PopulationCategory {
  final String name; // Nama kategori (e.g., 'Aktif', 'Laki-laki', 'Islam')
  final int count; // Jumlah
  final String color; // Warna untuk chart
  final double percentage; // Persentase

  PopulationCategory({
    required this.name,
    required this.count,
    required this.color,
    required this.percentage,
  });

  factory PopulationCategory.fromJson(Map<String, dynamic> json) {
    return PopulationCategory(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      color: json['color'] ?? '0xFF6EE7B7',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'color': color,
      'percentage': percentage,
    };
  }
}

/// Data untuk satu kategori analisis (misalnya: Gender)
class PopulationAnalysis {
  final String categoryTitle; // Judul kategori (e.g., 'Jenis Kelamin')
  final List<PopulationCategory> data; // Data dalam kategori

  PopulationAnalysis({required this.categoryTitle, required this.data});

  factory PopulationAnalysis.fromJson(Map<String, dynamic> json) {
    return PopulationAnalysis(
      categoryTitle: json['categoryTitle'] ?? '',
      data:
          (json['data'] as List?)
              ?.map((e) => PopulationCategory.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryTitle': categoryTitle,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

/// Complete Population Dashboard Data
class PopulationDashboardData {
  final PopulationSummary summary;
  final PopulationAnalysis residentStatus; // Status Penduduk (Aktif/Nonaktif)
  final PopulationAnalysis gender; // Jenis Kelamin
  final PopulationAnalysis occupation; // Pekerjaan
  final PopulationAnalysis religion; // Agama
  final PopulationAnalysis familyRole; // Peran dalam Keluarga
  final PopulationAnalysis education; // Pendidikan
  final DateTime lastUpdated;

  PopulationDashboardData({
    required this.summary,
    required this.residentStatus,
    required this.gender,
    required this.occupation,
    required this.religion,
    required this.familyRole,
    required this.education,
    required this.lastUpdated,
  });

  factory PopulationDashboardData.fromJson(Map<String, dynamic> json) {
    return PopulationDashboardData(
      summary: PopulationSummary.fromJson(json['summary'] ?? {}),
      residentStatus: PopulationAnalysis.fromJson(
        json['residentStatus'] ??
            {'categoryTitle': 'Status Penduduk', 'data': []},
      ),
      gender: PopulationAnalysis.fromJson(
        json['gender'] ?? {'categoryTitle': 'Jenis Kelamin', 'data': []},
      ),
      occupation: PopulationAnalysis.fromJson(
        json['occupation'] ?? {'categoryTitle': 'Pekerjaan', 'data': []},
      ),
      religion: PopulationAnalysis.fromJson(
        json['religion'] ?? {'categoryTitle': 'Agama', 'data': []},
      ),
      familyRole: PopulationAnalysis.fromJson(
        json['familyRole'] ??
            {'categoryTitle': 'Peran dalam Keluarga', 'data': []},
      ),
      education: PopulationAnalysis.fromJson(
        json['education'] ?? {'categoryTitle': 'Pendidikan', 'data': []},
      ),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'residentStatus': residentStatus.toJson(),
      'gender': gender.toJson(),
      'occupation': occupation.toJson(),
      'religion': religion.toJson(),
      'familyRole': familyRole.toJson(),
      'education': education.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
