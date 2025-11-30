# Quick Start Guide - Dashboard Setup

## 🚀 Getting Started

### 1. Review Struktur yang Telah Dibuat
```bash
lib/
├── models/dashboard_model.dart          # ✅ Ready
├── services/dashboard_service.dart      # ✅ Ready (dummy data)
├── repositories/dashboard_repository.dart # ✅ Ready
├── providers/dashboard_provider.dart    # ✅ Ready
└── screens/home/
    ├── home_screen.dart                 # ✅ Ready (needs Provider)
    ├── widgets/
    │   ├── dashboard_header.dart        # ✅ Ready
    │   └── dashboard_content.dart       # ✅ Ready
    ├── README.md                        # 📖 Documentation
    ├── API_INTEGRATION_GUIDE.md         # 📖 API Guide
    └── IMPLEMENTATION_REFERENCE.dart    # 📖 Code Examples
```

### 2. Setup Dependencies (Required untuk run)

Edit `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.0.0  # ← Add this
```

Run:
```bash
flutter pub get
```

### 3. Update main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Jawara Pintar',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

### 4. Test dengan Dummy Data

```bash
flutter run
```

Anda seharusnya melihat:
- 1 detik loading spinner
- Dashboard dengan 4 stat cards (Warga, Iuran, Pengaduan, Kegiatan)
- Pull-to-refresh support
- Clean UI dengan green theme

### 5. Integrasi API Real (Lihat API_INTEGRATION_GUIDE.md)

**Minimal setup:**
1. Buat `lib/constants/api_constants.dart`
2. Update `DashboardService.getDashboardData()`
3. Add http package: `http: ^1.1.0`
4. Test API call

---

## 📝 File-by-File Purpose

### Models Layer
**`models/dashboard_model.dart`**
- Struktur data untuk dashboard
- JSON serialization untuk API integration
- Type-safe data handling

### Services Layer
**`services/dashboard_service.dart`**
- Saat ini: Dummy data provider
- Nanti: HTTP API calls
- Template untuk migration sudah ada

### Repository Layer
**`repositories/dashboard_repository.dart`**
- Business logic abstraction
- Error handling
- Easy to mock for testing

### Provider Layer
**`providers/dashboard_provider.dart`**
- State management
- Loading/error/loaded states
- Notify UI of changes

### UI Widgets
**`screens/home/home_screen.dart`**
- Main screen
- Consumer widget untuk state
- Error handling UI
- Pull-to-refresh

**`screens/home/widgets/dashboard_header.dart`**
- Logo & title display
- Reusable component
- Positioned layout

**`screens/home/widgets/dashboard_content.dart`**
- Stat cards display
- Dynamic icon rendering
- Color-coded cards

---

## 🧪 Testing Dengan Dummy Data

### Scenarios to Test
1. ✅ Initial load - should show loading spinner
2. ✅ Data display - should show 4 stat cards
3. ✅ Pull-to-refresh - should reload data
4. ✅ Responsive - test on different screen sizes

### Test Commands
```bash
# Run app
flutter run

# Run tests
flutter test

# Run with verbose logging
flutter run -v
```

---

## 🔧 Troubleshooting

### Issue: "Provider not found"
**Solution:** Pastikan `MultiProvider` di main.dart sudah setup

### Issue: "Undefined reference: DashboardProvider"
**Solution:** `flutter pub get` dan pastikan import path benar

### Issue: Widgets tidak update
**Solution:** Gunakan `Consumer<DashboardProvider>` untuk listen changes

### Issue: Hot reload tidak bekerja
**Solution:** Hot restart atau compile ulang (`flutter run`)

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | Overview & checklist |
| `API_INTEGRATION_GUIDE.md` | Step-by-step API integration |
| `IMPLEMENTATION_REFERENCE.dart` | Code examples & patterns |
| `DASHBOARD_REFACTOR_SUMMARY.md` | Complete refactor summary |
| `DASHBOARD_ARCHITECTURE.md` | Architecture diagrams |
| `QUICK_START_GUIDE.md` | This file |

---

## 🎯 Next Steps

### Phase 1: Verify Dummy Data (Today)
- [ ] `flutter pub get`
- [ ] Update main.dart
- [ ] Run app
- [ ] Verify dummy data displays

### Phase 2: Setup API Constants (Day 1)
- [ ] Create `lib/constants/api_constants.dart`
- [ ] Define API base URL & endpoints
- [ ] Add timeout configuration

### Phase 3: HTTP Integration (Day 1-2)
- [ ] Add http package to pubspec.yaml
- [ ] Implement real API call in DashboardService
- [ ] Add error handling
- [ ] Test with real API

### Phase 4: Testing & Optimization (Day 2-3)
- [ ] Unit tests untuk service
- [ ] Widget tests untuk UI
- [ ] Performance monitoring
- [ ] Error scenario testing

### Phase 5: Production Ready (Day 3)
- [ ] Environment configuration
- [ ] Caching implementation
- [ ] Security review
- [ ] Monitoring setup
- [ ] Deploy

---

## ⏱️ Timeline Estimate

| Phase | Duration | Priority |
|-------|----------|----------|
| Verify Dummy Data | 30 min | High |
| API Setup | 1-2 hours | High |
| HTTP Integration | 2-3 hours | High |
| Testing | 2-3 hours | Medium |
| Optimization | 1-2 hours | Medium |
| **Total** | **7-11 hours** | - |

---

## 💡 Pro Tips

1. **Start with dummy data** - Verify UI works first
2. **Keep error handling** - User-friendly messages matter
3. **Test offline scenarios** - Network reliability is critical
4. **Monitor API calls** - Track response times
5. **Implement caching** - Better UX with offline support
6. **Document API changes** - Keep team aligned

---

## 📞 Support Resources

- **Flutter Docs:** https://flutter.dev/docs
- **Provider Package:** https://pub.dev/packages/provider
- **HTTP Package:** https://pub.dev/packages/http
- **Dart JSON:** https://dart.dev/guides/json

---

## ✨ Final Checklist

- [ ] Reviewed all files created
- [ ] Added provider to pubspec.yaml
- [ ] Updated main.dart
- [ ] Ran `flutter pub get`
- [ ] Tested app with dummy data
- [ ] Read API_INTEGRATION_GUIDE.md
- [ ] Created api_constants.dart
- [ ] Ready for API integration

---

**Generated:** November 27, 2025
**Version:** 1.0
**Status:** Ready for Development
