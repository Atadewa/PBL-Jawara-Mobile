enum JenisKelamin {
  lakiLaki,
  perempuan;

  String get label {
    switch (this) {
      case JenisKelamin.lakiLaki:
        return 'Laki-laki';
      case JenisKelamin.perempuan:
        return 'Perempuan';
    }
  }
}

enum Agama {
  islam,
  kristen,
  katolik,
  hindu,
  buddha,
  konghucu;

  String get label {
    switch (this) {
      case Agama.islam:
        return 'Islam';
      case Agama.kristen:
        return 'Kristen';
      case Agama.katolik:
        return 'Katolik';
      case Agama.hindu:
        return 'Hindu';
      case Agama.buddha:
        return 'Buddha';
      case Agama.konghucu:
        return 'Konghucu';
    }
  }
}

enum Pendidikan {
  tidakSekolah,
  sd,
  smp,
  sma,
  diploma,
  sarjana,
  magister,
  doktor;

  String get label {
    switch (this) {
      case Pendidikan.tidakSekolah:
        return 'Tidak Sekolah';
      case Pendidikan.sd:
        return 'SD';
      case Pendidikan.smp:
        return 'SMP';
      case Pendidikan.sma:
        return 'SMA';
      case Pendidikan.diploma:
        return 'Diploma';
      case Pendidikan.sarjana:
        return 'Sarjana';
      case Pendidikan.magister:
        return 'Magister';
      case Pendidikan.doktor:
        return 'Doktor';
    }
  }
}

enum HubunganKeluarga {
  kepalaKeluarga,
  istri,
  anak,
  orangTua,
  mertua,
  menantu,
  cucu,
  saudara,
  lainnya;

  String get label {
    switch (this) {
      case HubunganKeluarga.kepalaKeluarga:
        return 'Kepala Keluarga';
      case HubunganKeluarga.istri:
        return 'Istri';
      case HubunganKeluarga.anak:
        return 'Anak';
      case HubunganKeluarga.orangTua:
        return 'Orang Tua';
      case HubunganKeluarga.mertua:
        return 'Mertua';
      case HubunganKeluarga.menantu:
        return 'Menantu';
      case HubunganKeluarga.cucu:
        return 'Cucu';
      case HubunganKeluarga.saudara:
        return 'Saudara';
      case HubunganKeluarga.lainnya:
        return 'Lainnya';
    }
  }
}

enum StatusWarga {
  aktif,
  pindah,
  meninggal;

  String get label {
    switch (this) {
      case StatusWarga.aktif:
        return 'Aktif';
      case StatusWarga.pindah:
        return 'Pindah';
      case StatusWarga.meninggal:
        return 'Meninggal';
    }
  }
}

class WargaModel {
  final String nik;
  final String nama;
  final JenisKelamin jenisKelamin;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final Agama agama;
  final Pendidikan pendidikan;
  final String pekerjaan;
  final HubunganKeluarga hubunganKeluarga;
  final StatusWarga status;
  final String? noTelepon;

  WargaModel({
    required this.nik,
    required this.nama,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.agama,
    required this.pendidikan,
    required this.pekerjaan,
    required this.hubunganKeluarga,
    required this.status,
    this.noTelepon,
  });

  int get umur {
    final now = DateTime.now();
    int age = now.year - tanggalLahir.year;
    if (now.month < tanggalLahir.month ||
        (now.month == tanggalLahir.month && now.day < tanggalLahir.day)) {
      age--;
    }
    return age;
  }
}
