# E2E Testing - Aktivitas & Broadcast Feature

## Overview
E2E testing untuk fitur Aktivitas & Broadcast pada aplikasi mobile. 
Test dibuat langsung untuk fitur tanpa memerlukan proses login.

## Struktur File

```
test/e2e/aktivitasdanbroadcast/
├── aktivitas_broadcast_e2e.dart     # Main test library file
├── aktivitas_broadcast_test.dart    # Test untuk halaman utama
├── detail_pages_test.dart           # Test untuk halaman detail
├── widgets_test.dart                # Test untuk widget components
├── mocks/
│   └── mock_aktivitas_service.dart  # Mock service untuk testing
└── robots/
    ├── aktivitas_robot.dart         # Robot pattern untuk main page
    └── detail_robot.dart            # Robot pattern untuk detail pages
```

## Test Cases

### Main Page Tests (aktivitas_broadcast_test.dart)
| TC | Nama | Deskripsi |
|----|------|-----------|
| TC01 | Page Loaded | Halaman berhasil dimuat |
| TC02 | Tab Navigation | Switch antara tab Kegiatan dan Broadcast |
| TC03 | List Kegiatan | Menampilkan list kegiatan |
| TC04 | List Broadcast | Menampilkan list broadcast |
| TC05 | Search Kegiatan | Search dengan keyword |
| TC06 | Clear Search | Clear search field |
| TC07 | Tap Kegiatan Card | Navigasi ke detail kegiatan |
| TC08 | Tap Broadcast Card | Navigasi ke detail broadcast |
| TC09 | FAB Visibility | FAB tambah kegiatan terlihat |
| TC10 | Tap FAB | Navigasi ke halaman tambah |
| TC11 | More Options | Bottom sheet more options |
| TC12 | Empty State Kegiatan | Empty state tampil |
| TC13 | Empty State Broadcast | Empty state tampil |
| TC14 | Error State | Error dengan retry button |
| TC15 | Loading State | Loading indicator |
| TC16 | Full Flow | Complete user flow |
| TC17 | Scroll Kegiatan | Scroll list kegiatan |
| TC18 | Scroll Broadcast | Scroll list broadcast |
| TC19 | Search Not Found | Search tanpa hasil |
| TC20 | Tab Bar Styling | Styling tab bar |

### Detail Pages Tests (detail_pages_test.dart)
| TC | Nama | Deskripsi |
|----|------|-----------|
| TC01-06 | Detail Kegiatan | Test halaman detail kegiatan |
| TC07-10 | Detail Broadcast | Test halaman detail broadcast |
| TC11-14 | Add Kegiatan | Test form tambah kegiatan |
| TC15-17 | Add Broadcast | Test form tambah broadcast |
| TC18-19 | Delete Dialog | Test dialog hapus |
| TC20 | Error Handling | Error state pada detail |

### Widget Tests (widgets_test.dart)
| TC | Nama | Deskripsi |
|----|------|-----------|
| TC01-08 | KegiatanCard | Test widget KegiatanCard |
| TC09-15 | BroadcastCard | Test widget BroadcastCard |
| TC16-18 | Card List | Test multiple cards dalam list |

## Cara Menjalankan Test

### Semua Test Aktivitas & Broadcast
```bash
flutter test test/e2e/aktivitasdanbroadcast/
```

### Test Tertentu
```bash
# Main page tests
flutter test test/e2e/aktivitasdanbroadcast/aktivitas_broadcast_test.dart

# Detail pages tests
flutter test test/e2e/aktivitasdanbroadcast/detail_pages_test.dart

# Widget tests
flutter test test/e2e/aktivitasdanbroadcast/widgets_test.dart
```

### Dengan Verbose Output
```bash
flutter test test/e2e/aktivitasdanbroadcast/ --reporter expanded
```

### Test Tertentu dengan Name Filter
```bash
flutter test test/e2e/aktivitasdanbroadcast/ --name "TC01"
```

## Robot Pattern

Test menggunakan Robot Pattern untuk memisahkan:
- **Test File**: Berisi test cases dan assertions
- **Robot File**: Berisi actions dan finders

Keuntungan:
- Maintainability: Perubahan UI hanya perlu update di robot file
- Readability: Test cases lebih mudah dibaca
- Reusability: Actions dapat digunakan di multiple tests

## Mock Service

`MockAktivitasService` menyediakan data dummy untuk testing:
- `MockMode.normal`: Data lengkap
- `MockMode.empty`: Tanpa data (empty state)
- `MockMode.error`: Throw exception (error state)
- `MockMode.loading`: Delay panjang (loading state)

## Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  google_fonts: ^6.0.0
```

## Notes

- Test tidak memerlukan login (langsung ke fitur)
- Menggunakan `GoogleFonts.config.allowRuntimeFetching = false` untuk disable font loading
- Mock service menggantikan API calls untuk isolasi testing
- Robot pattern untuk maintainable test code
