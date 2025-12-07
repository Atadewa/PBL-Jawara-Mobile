import 'package:flutter/material.dart';

enum ExpenseCategory {
  keamananKebersihan('Keamanan dan Kebersihan', Color(0xFFD0FAE5), Color(0xFF007955)),
  pemeliharaanFasilitas('Pemeliharaan Fasilitas', Color(0xFFFFEDD4), Color(0xFFC93400)),
  kegiatanWarga('Kegiatan Warga', Color(0xFFFCE7F3), Color(0xFFC6005B)),
  pembangunan('Pembangunan', Color(0xFFE0E7FF), Color(0xFF432DD7));

  final String label;
  final Color backgroundColor;
  final Color textColor;

  const ExpenseCategory(this.label, this.backgroundColor, this.textColor);

  static ExpenseCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'keamanan dan kebersihan':
        return ExpenseCategory.keamananKebersihan;
      case 'pemeliharaan fasilitas':
        return ExpenseCategory.pemeliharaanFasilitas;
      case 'kegiatan warga':
        return ExpenseCategory.kegiatanWarga;
      case 'pembangunan':
        return ExpenseCategory.pembangunan;
      default:
        return ExpenseCategory.keamananKebersihan;
    }
  }
}
