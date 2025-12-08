/// Model untuk Activity Dashboard

import 'common_model.dart';

/// Summary data untuk aktivitas
class ActivitySummary {
  final String totalActivities; // Total kegiatan tahun ini
  final String completed; // Kegiatan selesai
  final String today; // Kegiatan hari ini
  final String upcoming; // Kegiatan mendatang

  ActivitySummary({
    required this.totalActivities,
    required this.completed,
    required this.today,
    required this.upcoming,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      totalActivities: json['totalActivities']?.toString() ?? '0',
      completed: json['completed']?.toString() ?? '0',
      today: json['today']?.toString() ?? '0',
      upcoming: json['upcoming']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalActivities': totalActivities,
      'completed': completed,
      'today': today,
      'upcoming': upcoming,
    };
  }
}

/// Kategori kegiatan breakdown
class ActivityCategory {
  final String category;
  final int count;
  final String color;
  final double percentage;

  ActivityCategory({
    required this.category,
    required this.count,
    required this.color,
    required this.percentage,
  });

  factory ActivityCategory.fromJson(Map<String, dynamic> json) {
    return ActivityCategory(
      category: json['category'] ?? '',
      count: json['count'] ?? 0,
      color: json['color'] ?? '0xFF6EE7B7',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count': count,
      'color': color,
      'percentage': percentage,
    };
  }
}

/// Person ranking (penanggung jawab)
class PersonRanking {
  final int rank; // 1, 2, 3, 4
  final String name;
  final int activityCount;
  final String color; // Avatar background color

  PersonRanking({
    required this.rank,
    required this.name,
    required this.activityCount,
    required this.color,
  });

  factory PersonRanking.fromJson(Map<String, dynamic> json) {
    return PersonRanking(
      rank: json['rank'] ?? 0,
      name: json['name'] ?? '',
      activityCount: json['activityCount'] ?? 0,
      color: json['color'] ?? '0xFF6EE7B7',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'name': name,
      'activityCount': activityCount,
      'color': color,
    };
  }
}

/// Complete Activity Dashboard Data
class ActivityDashboardData {
  final ActivitySummary summary;
  final List<MonthlySeries> monthlyActivities; // Data kegiatan per bulan
  final List<ActivityCategory> categories; // Kegiatan per kategori
  final List<PersonRanking> topResponsiblePersons; // Top 4 penanggung jawab
  final DateTime lastUpdated;

  ActivityDashboardData({
    required this.summary,
    required this.monthlyActivities,
    required this.categories,
    required this.topResponsiblePersons,
    required this.lastUpdated,
  });

  factory ActivityDashboardData.fromJson(Map<String, dynamic> json) {
    return ActivityDashboardData(
      summary: ActivitySummary.fromJson(json['summary'] ?? {}),
      monthlyActivities:
          (json['monthlyActivities'] as List?)
              ?.map((e) => MonthlySeries.fromJson(e))
              .toList() ??
          [],
      categories:
          (json['categories'] as List?)
              ?.map((e) => ActivityCategory.fromJson(e))
              .toList() ??
          [],
      topResponsiblePersons:
          (json['topResponsiblePersons'] as List?)
              ?.map((e) => PersonRanking.fromJson(e))
              .toList() ??
          [],
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'monthlyActivities': monthlyActivities.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'topResponsiblePersons': topResponsiblePersons
          .map((e) => e.toJson())
          .toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
