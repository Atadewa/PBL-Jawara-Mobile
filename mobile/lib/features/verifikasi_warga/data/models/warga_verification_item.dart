import 'warga_verification_status.dart';

class WargaVerificationItem {
  final String id;
  final String nama;
  final String nik;
  final int umur;
  final String diajukanOleh;
  final DateTime tanggalPengajuan;
  final WargaVerificationStatus status;
  
  // Additional fields for detail page
  final DateTime? tanggalLahir;
  final String? jenisKelamin;
  final String? agama;
  final String? pendidikan;
  final String? pekerjaan;
  final String? nomorTelepon;
  final String? kepalaKeluarga;
  final String? keluarga;
  final String? alamat;

  WargaVerificationItem({
    required this.id,
    required this.nama,
    required this.nik,
    required this.umur,
    required this.diajukanOleh,
    required this.tanggalPengajuan,
    required this.status,
    this.tanggalLahir,
    this.jenisKelamin,
    this.agama,
    this.pendidikan,
    this.pekerjaan,
    this.nomorTelepon,
    this.kepalaKeluarga,
    this.keluarga,
    this.alamat,
  });

  factory WargaVerificationItem.fromJson(Map<String, dynamic> json) {
    return WargaVerificationItem(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      nik: json['nik'] ?? '',
      umur: json['umur'] ?? 0,
      diajukanOleh: json['diajukan_oleh'] ?? '',
      tanggalPengajuan: DateTime.parse(json['tanggal_pengajuan']),
      status: WargaVerificationStatus.fromString(json['status'] ?? 'pending'),
      tanggalLahir: json['tanggal_lahir'] != null 
          ? DateTime.parse(json['tanggal_lahir']) 
          : null,
      jenisKelamin: json['jenis_kelamin'],
      agama: json['agama'],
      pendidikan: json['pendidikan'],
      pekerjaan: json['pekerjaan'],
      nomorTelepon: json['nomor_telepon'],
      kepalaKeluarga: json['kepala_keluarga'],
      keluarga: json['keluarga'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nik': nik,
      'umur': umur,
      'diajukan_oleh': diajukanOleh,
      'tanggal_pengajuan': tanggalPengajuan.toIso8601String(),
      'status': status.displayName,
      'tanggal_lahir': tanggalLahir?.toIso8601String(),
      'jenis_kelamin': jenisKelamin,
      'agama': agama,
      'pendidikan': pendidikan,
      'pekerjaan': pekerjaan,
      'nomor_telepon': nomorTelepon,
      'kepala_keluarga': kepalaKeluarga,
      'keluarga': keluarga,
      'alamat': alamat,
    };
  }
}
