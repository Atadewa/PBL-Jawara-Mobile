/// Model untuk data statistik home
class HomeStats {
  final int totalWarga;
  final int totalKeluarga;
  final String pemasukan;
  final String pengeluaran;

  HomeStats({
    required this.totalWarga,
    required this.totalKeluarga,
    required this.pemasukan,
    required this.pengeluaran,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      totalWarga: json['total_warga'] ?? 0,
      totalKeluarga: json['total_keluarga'] ?? 0,
      pemasukan: json['pemasukan'] ?? '0',
      pengeluaran: json['pengeluaran'] ?? '0',
    );
  }
}
