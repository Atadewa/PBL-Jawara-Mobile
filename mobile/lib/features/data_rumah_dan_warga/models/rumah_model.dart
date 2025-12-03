class RumahModel {
  final String blok;
  final String nomor;
  final String alamatLengkap;
  final StatusRumah status;
  final int jumlahKeluarga;

  RumahModel({
    required this.blok,
    required this.nomor,
    required this.alamatLengkap,
    required this.status,
    required this.jumlahKeluarga,
  });

  String get nomorRumah => 'Blok $blok / No. $nomor';
}

enum StatusRumah { dihuni, kosong, dalamRenovasi }

extension StatusRumahExtension on StatusRumah {
  String get label {
    switch (this) {
      case StatusRumah.dihuni:
        return 'Dihuni';
      case StatusRumah.kosong:
        return 'Kosong';
      case StatusRumah.dalamRenovasi:
        return 'Dalam Renovasi';
    }
  }
}
