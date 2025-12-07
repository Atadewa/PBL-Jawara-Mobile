/// Model untuk dashboard data
///
/// Struktur ini didesain untuk mudah di-serialize/deserialize dari API JSON
class DashboardData {
  final String title;
  final String subtitle;
  final List<DashboardWidget> widgets;
  final String userLocation;
  final DateTime lastUpdated;

  DashboardData({
    required this.title,
    required this.subtitle,
    required this.widgets,
    required this.userLocation,
    required this.lastUpdated,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      title: json['title'] ?? 'Masuk ke Jawara Pintar',
      subtitle:
          json['subtitle'] ??
          'Kelola lingkungan RT/RW Anda secara mudah dan modern',
      widgets:
          (json['widgets'] as List?)
              ?.map((w) => DashboardWidget.fromJson(w))
              .toList() ??
          [],
      userLocation: json['userLocation'] ?? 'RT 01 / RW 05',
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'widgets': widgets.map((w) => w.toJson()).toList(),
      'userLocation': userLocation,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// Model untuk individual dashboard widget (stat card)
class DashboardWidget {
  final String id;
  final String type; // 'stat_card', 'action_card', etc
  final String title;
  final dynamic value; // Can be int, String, or other types
  final String? icon;
  final String? color;

  DashboardWidget({
    required this.id,
    required this.type,
    required this.title,
    required this.value,
    this.icon,
    this.color,
  });

  factory DashboardWidget.fromJson(Map<String, dynamic> json) {
    return DashboardWidget(
      id: json['id'] ?? '',
      type: json['type'] ?? 'stat_card',
      title: json['title'] ?? '',
      value: json['value'],
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'value': value,
      'icon': icon,
      'color': color,
    };
  }
}

/// Model untuk stat card yang ditampilkan di bagian atas
class StatCard {
  final String id;
  final String label;
  final dynamic value;
  final String borderColor;
  final String backgroundColor;
  final String icon;

  StatCard({
    required this.id,
    required this.label,
    required this.value,
    required this.borderColor,
    required this.backgroundColor,
    required this.icon,
  });
}

/// Model untuk action card (Dashboard Keuangan, Kegiatan, etc)
class ActionCard {
  final String id;
  final String title;
  final String description;
  final String icon;

  ActionCard({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Model untuk quick menu item
class QuickMenuItem {
  final String id;
  final String label;
  final String icon;

  QuickMenuItem({required this.id, required this.label, required this.icon});
}
