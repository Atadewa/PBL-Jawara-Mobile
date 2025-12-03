class KeluargaModel {
  final String nama;
  final String kk;
  final StatusKeluarga status;
  final int jumlahAnggota;

  KeluargaModel({
    required this.nama,
    required this.kk,
    required this.status,
    required this.jumlahAnggota,
  });

  String get anggotaText => '$jumlahAnggota Anggota';
}

enum StatusKeluarga { aktif, pindahMasuk, tidakAktif }

extension StatusKeluargaExtension on StatusKeluarga {
  String get label {
    switch (this) {
      case StatusKeluarga.aktif:
        return 'Aktif';
      case StatusKeluarga.pindahMasuk:
        return 'Pindah Masuk';
      case StatusKeluarga.tidakAktif:
        return 'Tidak Aktif';
    }
  }
}
