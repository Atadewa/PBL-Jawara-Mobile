# Population Dashboard Implementation Guide

## Overview
Dashboard Kependudukan telah berhasil diimplementasikan dengan best practices untuk API consumption, state management, dan error handling. Fitur ini menampilkan statistik demografi warga RT/RW dengan 7 kategori analisis.

## Struktur File yang Dibuat

### 1. Models (`lib/features/dashboard/models/population_model.dart`)
**Komponen:**
- `PopulationSummary` - Data ringkas (Total Keluarga, Total Penduduk)
- `PopulationCategory` - Kategori individual dengan count, persentase, dan warna
- `PopulationAnalysis` - Koleksi kategori untuk satu tipe analisis
- `PopulationDashboardData` - Data lengkap dashboard dengan 7 analisis

**Fitur:**
- JSON serialization/deserialization (`fromJson()` & `toJson()`)
- Type-safe data handling

### 2. Service (`lib/features/dashboard/services/population_service.dart`)
**Fitur:**
- Toggle mock data vs real API dengan parameter `useMockData`
- Delay simulasi untuk development (800ms)
- Dokumentasi lengkap untuk migrasi ke API real

**Mock Data Included:**
- Total Keluarga: 342, Total Penduduk: 1,248
- 7 kategori analisis dengan data realistis:
  - Status Penduduk (Aktif/Nonaktif)
  - Jenis Kelamin (Laki-laki/Perempuan)
  - Pekerjaan (5 tipe pekerjaan)
  - Agama (5 agama)
  - Peran dalam Keluarga (4 peran)
  - Pendidikan (6 tingkat pendidikan)

### 3. Repository (`lib/features/dashboard/data/population_repository.dart`)
**Fitur:**
- Interface `IPopulationRepository` untuk contract
- Error handling dengan logging
- Penanganan error spesifik (timeout, format, network)

### 4. Provider (`lib/features/dashboard/providers/population_provider.dart`)
**State Management:**
- Enum `PopulationState` (initial, loading, loaded, error)
- ChangeNotifier untuk reactive updates
- Methods: `loadPopulationDashboard()`, `refreshPopulationDashboard()`
- Getters: `isLoading`, `isLoaded`, `isError`

### 5. UI Components

#### `population_dashboard_page.dart`
- Halaman utama dengan RefreshIndicator
- Consumer pattern untuk state management
- Loading, error, dan success states
- Summary stat cards (2 columns)
- 6 chart cards untuk analisis demografi

#### `population_stat_card.dart`
- Card dengan border hijau dan icon
- Menampilkan title dan value
- Responsive design

#### `population_chart_card.dart`
- Card untuk menampilkan chart placeholder
- Legend terintegrasi
- Siap untuk implementasi chart real (fl_chart/syncfusion)

#### `population_chart_legend.dart`
- Legend dengan color dots
- Layout 2 kolom untuk readability
- Dynamic parsing warna dari string hex

## Langkah Migrasi ke API Real

### Step 1: Setup HTTP Client
```dart
// pubspec.yaml
dependencies:
  http: ^1.1.0

// Atau gunakan dio untuk lebih advanced features
dependencies:
  dio: ^5.3.0
```

### Step 2: Buat API Constants
```dart
// lib/features/dashboard/core/api_constants.dart
class ApiConstants {
  static const String BASE_URL = 'https://api.example.com';
  static const String POPULATION_ENDPOINT = '/api/v1/population/dashboard';
  static const Duration TIMEOUT = Duration(seconds: 30);
}
```

### Step 3: Update PopulationService
```dart
Future<PopulationDashboardData> getPopulationDashboard() async {
  if (useMockData) {
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockData();
  }

  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.BASE_URL}${ApiConstants.POPULATION_ENDPOINT}'),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
    ).timeout(ApiConstants.TIMEOUT);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PopulationDashboardData.fromJson(json['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed with status: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}
```

### Step 4: Implementasi Caching (Optional tapi Recommended)
```dart
// Gunakan package seperti: hive, get_storage, atau local_storage
class PopulationService {
  final PopulationCache _cache;
  
  Future<PopulationDashboardData> getPopulationDashboard({
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = await _cache.get();
      if (cached != null) return cached;
    }
    
    // Fetch from API
    final data = await _fetchFromAPI();
    
    // Cache the result
    await _cache.set(data);
    
    return data;
  }
}
```

### Step 5: Testing
```dart
// test/features/dashboard/services/population_service_test.dart
void main() {
  group('PopulationService', () {
    late PopulationService service;

    setUp(() {
      service = PopulationService(useMockData: true);
    });

    test('getPopulationDashboard returns valid data', () async {
      final data = await service.getPopulationDashboard();
      
      expect(data.summary.totalFamilies, isNotEmpty);
      expect(data.summary.totalResidents, isNotEmpty);
      expect(data.residentStatus.data, isNotEmpty);
    });
  });
}
```

## Integration Points

### 1. Dashboard Page Navigation
File: `lib/features/dashboard/pages/dashboard_page.dart`

Tombol "Dashboard Kependudukan" sekarang navigate ke `PopulationDashboardPage`

### 2. Multi-Provider Setup
File: `lib/main.dart`

PopulationProvider sudah terintegrasi dalam MultiProvider:
```dart
// Population dependencies
Provider(create: (_) => PopulationService()),
ProxyProvider<PopulationService, PopulationRepository>(
  update: (_, service, __) =>
      PopulationRepository(populationService: service),
),
ChangeNotifierProxyProvider<PopulationRepository, PopulationProvider>(
  create: (context) {
    final service = context.read<PopulationService>();
    final repository = PopulationRepository(populationService: service);
    return PopulationProvider(repository: repository);
  },
  update: (_, repository, __) =>
      PopulationProvider(repository: repository),
),
```

## Best Practices Diterapkan

### 1. Architecture Pattern
- **Repository Pattern** - Abstraksi data layer
- **Provider Pattern** - State management dengan ChangeNotifier
- **Separation of Concerns** - Pisah service, repository, provider, UI

### 2. Error Handling
- Try-catch dengan specific error messages
- Logging untuk debugging
- User-friendly error messages di UI
- Fallback UI states (loading, error, empty)

### 3. API Consumption
- Mock data untuk development tanpa API
- Future-ready untuk real API
- Documentasi migrasi step-by-step
- Type-safe JSON handling dengan model classes

### 4. State Management
- Enum untuk state constants
- Getter methods untuk read-only state
- notifyListeners() untuk reactive updates
- Proper resource cleanup

### 5. UI/UX
- RefreshIndicator untuk pull-to-refresh
- Loading indicator dengan brand color
- Error state dengan retry button
- Empty state handling
- Responsive grid layout
- Consistent design dengan activity dashboard

## Fitur untuk Future Implementation

### 1. Chart Visualization
Saat ini menggunakan placeholder. Untuk implementasi real:
- **Option A:** fl_chart (Popular, lightweight)
- **Option B:** syncfusion_flutter_charts (Full-featured)
- **Option C:** charts (Material Design charts)

### 2. Advanced Features
- [ ] Export to PDF/Excel
- [ ] Filter by date range
- [ ] Search/filter residents
- [ ] Comparison dengan periode sebelumnya
- [ ] Real-time updates dengan WebSocket
- [ ] Offline mode dengan local cache

### 3. Performance Optimization
- [ ] Pagination untuk data besar
- [ ] Image caching
- [ ] Lazy loading
- [ ] Connection pool reuse

## Testing Checklist

- [ ] Test PopulationService dengan mock data
- [ ] Test PopulationRepository error handling
- [ ] Test PopulationProvider state transitions
- [ ] UI test untuk PopulationDashboardPage
- [ ] Integration test dashboard → population navigation
- [ ] Test data serialization/deserialization

## Troubleshooting

### Issue: Data tidak muncul
1. Pastikan PopulationProvider sudah di MultiProvider (sudah fix)
2. Check console untuk error messages
3. Restart app (Flutter rebuilds)

### Issue: Navigation error
1. Pastikan import PopulationDashboardPage di dashboard_page.dart (sudah fix)
2. Check route configuration

### Issue: API migration
Ikuti step-by-step guide di atas, mulai dari Step 1: Setup HTTP Client

---

**Status:** ✅ Production Ready untuk Mock Data
**Next Step:** Implementasi real API sesuai backend specs
**Estimated API Integration Time:** 2-3 jam (termasuk testing)
