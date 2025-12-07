/// Common models yang digunakan di multiple dashboards

/// Monthly data untuk chart (digunakan di Finance dan Activity)
class MonthlySeries {
  final String month;
  final int value;

  MonthlySeries({required this.month, required this.value});

  factory MonthlySeries.fromJson(Map<String, dynamic> json) {
    return MonthlySeries(month: json['month'] ?? '', value: json['value'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'value': value};
  }
}
