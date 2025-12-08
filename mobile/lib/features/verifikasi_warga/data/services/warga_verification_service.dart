import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/warga_verification_item.dart';
import '../models/warga_verification_status.dart';

class WargaVerificationService {
  static const String _endpoint = '/warga-verification';

  // Get all pending verifications
  Future<List<WargaVerificationItem>> getPendingVerifications() async {
    if (ApiConfig.useDummyData) {
      return _getDummyVerifications();
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$_endpoint/pending');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => WargaVerificationItem.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load verifications');
      }
    } catch (e) {
      throw Exception('Error fetching verifications: $e');
    }
  }

  // Approve verification
  Future<bool> approveVerification(String id) async {
    if (ApiConfig.useDummyData) {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$_endpoint/$id/approve');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error approving verification: $e');
    }
  }

  // Reject verification
  Future<bool> rejectVerification(String id, String reason) async {
    if (ApiConfig.useDummyData) {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$_endpoint/$id/reject');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'reason': reason}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error rejecting verification: $e');
    }
  }

  // Dummy data for testing
  List<WargaVerificationItem> _getDummyVerifications() {
    return [
      WargaVerificationItem(
        id: '1',
        nama: 'Budi Santoso',
        nik: '3201012345670001',
        umur: 28,
        diajukanOleh: 'Warga',
        tanggalPengajuan: DateTime(2024, 11, 20),
        status: WargaVerificationStatus.pending,
        tanggalLahir: DateTime(1996, 5, 15),
        jenisKelamin: 'Laki-laki',
        agama: 'Islam',
        pendidikan: 'S1',
        pekerjaan: 'Pegawai Swasta',
        nomorTelepon: '081234567890',
        kepalaKeluarga: 'Budi Santoso',
        keluarga: 'Keluarga Santoso',
        alamat: 'Jl. Mawar No. 123, RT 01/RW 05',
      ),
      WargaVerificationItem(
        id: '2',
        nama: 'Siti Nurhaliza',
        nik: '3201012345670002',
        umur: 35,
        diajukanOleh: 'Kepala Keluarga',
        tanggalPengajuan: DateTime(2024, 11, 21),
        status: WargaVerificationStatus.pending,
        tanggalLahir: DateTime(1989, 8, 22),
        jenisKelamin: 'Perempuan',
        agama: 'Islam',
        pendidikan: 'S2',
        pekerjaan: 'Guru',
        nomorTelepon: '081234567891',
        kepalaKeluarga: 'Ahmad Nurhaliza',
        keluarga: 'Keluarga Nurhaliza',
        alamat: 'Jl. Melati No. 45, RT 02/RW 05',
      ),
      WargaVerificationItem(
        id: '3',
        nama: 'Ahmad Fauzi',
        nik: '3201012345670003',
        umur: 42,
        diajukanOleh: 'Warga',
        tanggalPengajuan: DateTime(2024, 11, 22),
        status: WargaVerificationStatus.pending,
        tanggalLahir: DateTime(1982, 3, 10),
        jenisKelamin: 'Laki-laki',
        agama: 'Islam',
        pendidikan: 'SMA',
        pekerjaan: 'Wiraswasta',
        nomorTelepon: '081234567892',
        kepalaKeluarga: 'Ahmad Fauzi',
        keluarga: 'Keluarga Fauzi',
        alamat: 'Jl. Kenanga No. 78, RT 03/RW 05',
      ),
      WargaVerificationItem(
        id: '4',
        nama: 'Dewi Lestari',
        nik: '3201012345670004',
        umur: 31,
        diajukanOleh: 'Kepala Keluarga',
        tanggalPengajuan: DateTime(2024, 11, 23),
        status: WargaVerificationStatus.pending,
        tanggalLahir: DateTime(1993, 12, 5),
        jenisKelamin: 'Perempuan',
        agama: 'Kristen',
        pendidikan: 'D3',
        pekerjaan: 'Perawat',
        nomorTelepon: '081234567893',
        kepalaKeluarga: 'Bambang Lestari',
        keluarga: 'Keluarga Lestari',
        alamat: 'Jl. Anggrek No. 90, RT 04/RW 05',
      ),
    ];
  }
}
