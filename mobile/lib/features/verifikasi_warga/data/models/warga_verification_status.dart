import 'package:flutter/material.dart';

enum WargaVerificationStatus {
  pending('Pending', Color(0xFFFEF3C7), Color(0xFFD97706)),
  approved('Disetujui', Color(0xFFD1FAE5), Color(0xFF059669)),
  rejected('Ditolak', Color(0xFFFEE2E2), Color(0xFFDC2626));

  final String displayName;
  final Color backgroundColor;
  final Color textColor;

  const WargaVerificationStatus(
      this.displayName, this.backgroundColor, this.textColor);

  static WargaVerificationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return WargaVerificationStatus.pending;
      case 'approved':
      case 'disetujui':
        return WargaVerificationStatus.approved;
      case 'rejected':
      case 'ditolak':
        return WargaVerificationStatus.rejected;
      default:
        return WargaVerificationStatus.pending;
    }
  }
}
