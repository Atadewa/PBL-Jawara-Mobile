<div align="center">
  
# 🏘️ Jawara Pintar

### Aplikasi Manajemen Lingkungan RT/RW Modern

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=flat&logo=node.js)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-5.0+-000000?style=flat&logo=express)](https://expressjs.com)
[![Supabase](https://img.shields.io/badge/Supabase-Latest-3ECF8E?style=flat&logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

_Solusi digital terpadu untuk pengelolaan administrasi, komunikasi, dan aktivitas warga RT/RW_

[Fitur](#-fitur-utama) • [Teknologi](#-teknologi-stack) • [Instalasi](#-instalasi) • [Tim](#-tim-pengembang)

</div>

---

## 📋 Daftar Isi

- [Tentang Proyek](#-tentang-proyek)
- [Fitur Utama](#-fitur-utama)
- [Teknologi Stack](#-teknologi-stack)
- [Arsitektur Sistem](#-arsitektur-sistem)
- [Instalasi](#-instalasi)
- [Penggunaan](#-penggunaan)
- [Struktur Proyek](#-struktur-proyek)
- [Testing](#-testing)
- [Tim Pengembang](#-tim-pengembang)
- [Lisensi](#-lisensi)

---

## 🎯 Tentang Proyek

**Jawara Pintar** adalah aplikasi mobile dan backend API yang dirancang untuk mempermudah pengelolaan lingkungan RT/RW. Aplikasi ini menyediakan solusi terpadu untuk:

- 📊 **Manajemen Data**: Pendataan warga, rumah, dan struktur keluarga secara terorganisir
- 💰 **Keuangan**: Pencatatan pemasukan, pengeluaran, dan laporan keuangan transparan
- 📢 **Komunikasi**: Broadcast pengumuman dan penyampaian aspirasi warga
- 📅 **Kegiatan**: Manajemen event dan kegiatan warga
- 🏪 **Marketplace**: Platform jual-beli produk lokal (khususnya batik)
- 🔐 **Keamanan**: Sistem autentikasi, verifikasi pengguna, dan log aktivitas

Proyek ini dikembangkan sebagai bagian dari mata kuliah **Project-Based Learning (PBL)** di **Politeknik Negeri Malang**, Semester 5.

---

## ✨ Fitur Utama

### 🔐 Autentikasi & Keamanan

- Login/Register dengan validasi
- Manajemen sesi pengguna berbasis JWT
- Role-based access control (Admin, RT, RW, Warga)
- Verifikasi pengguna baru
- Log aktivitas untuk audit trail

### 📊 Dashboard & Data Management

- Dashboard informatif dengan ringkasan data
- Pendataan rumah dan warga lengkap
- Struktur data keluarga
- Profil pengguna terperinci

### 💰 Manajemen Keuangan

- Pencatatan pemasukan RT/RW
- Pencatatan pengeluaran dengan kategori
- Laporan keuangan periodik
- Riwayat transaksi lengkap

### 📢 Komunikasi & Kegiatan

- Broadcast pengumuman ke seluruh warga
- Manajemen kegiatan/event warga
- Kanal aspirasi dan pesan warga
- Notifikasi real-time

### 🏪 Marketplace

- Platform jual-beli produk lokal
- Katalog produk batik
- Manajemen transaksi

### 📝 Log & Monitoring

- Audit trail aktivitas penting
- Monitoring akses pengguna
- Riwayat perubahan data

---

## 🛠️ Teknologi Stack

### Mobile App (Flutter)

```yaml
Framework: Flutter 3.9.2
Language: Dart ^3.9.2
State Management: Provider, Riverpod
UI/UX: Material Design, Google Fonts
```

**Dependencies Utama:**

- `supabase_flutter`: ^2.3.4 - Backend as a Service
- `provider`: ^6.1.5 - State management
- `flutter_riverpod`: ^2.4.0 - Advanced state management
- `http`: ^1.2.0 & `dio`: ^5.4.0 - HTTP client
- `google_fonts`: ^6.2.1 - Custom fonts
- `image_picker`: ^1.0.7 - Upload gambar
- `intl`: ^0.20.2 - Internationalization

### Backend API (Node.js)

```json
Runtime: Node.js 18+
Framework: Express 5.2.1
Database: Supabase (PostgreSQL)
```

**Dependencies Utama:**

- `express`: ^5.2.1 - Web framework
- `@supabase/supabase-js`: ^2.87.1 - Database client
- `cors`: ^2.8.5 - Cross-Origin Resource Sharing
- `multer`: ^2.0.2 - File upload handling
- `dotenv`: ^17.2.3 - Environment variables

**Development Tools:**

- `jest`: ^30.2.0 - Testing framework
- `supertest`: ^7.1.4 - HTTP testing
- `nodemon`: ^3.1.11 - Auto-reload server

### Database & Backend Services

- **Supabase**: Authentication, PostgreSQL Database, Storage, Real-time subscriptions
- **Vercel**: Backend deployment

---

## 🏗️ Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   UI Layer  │  │  Features   │  │    Core     │     │
│  │  (Widgets)  │  │ (Business)  │  │ (Services)  │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└────────────────────────┬────────────────────────────────┘
                         │ HTTP/REST API
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Express.js Backend API                      │
│  ┌──────────┐  ┌───────────┐  ┌──────────────┐        │
│  │  Routes  │→ │Middleware │→ │  Controllers │        │
│  └──────────┘  └───────────┘  └──────────────┘        │
└────────────────────────┬────────────────────────────────┘
                         │ Supabase Client
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    Supabase Backend                      │
│  ┌──────────┐  ┌──────────┐  ┌─────────┐  ┌─────────┐ │
│  │   Auth   │  │PostgreSQL│  │ Storage │  │Realtime │ │
│  └──────────┘  └──────────┘  └─────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 📥 Instalasi

### Prerequisites

Pastikan sudah terinstall:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0 atau lebih baru)
- [Node.js](https://nodejs.org/) (18 atau lebih baru)
- [Git](https://git-scm.com/)
- Editor: [VS Code](https://code.visualstudio.com/) atau [Android Studio](https://developer.android.com/studio)

### Clone Repository

```bash
git clone https://github.com/your-username/jawara-pintar.git
cd jawara-pintar
```

### Setup Backend

1. Masuk ke direktori backend:

```bash
cd backend
```

2. Install dependencies:

```bash
npm install
```

3. Buat file `.env` berdasarkan `.env.example`:

```bash
cp .env.example .env
```

4. Konfigurasi environment variables di `.env`:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
PORT=3000
```

5. Jalankan server development:

```bash
npm run dev
```

Server akan berjalan di `http://localhost:3000`

### Setup Mobile App

1. Masuk ke direktori mobile:

```bash
cd mobile
```

2. Install dependencies:

```bash
flutter pub get
```

3. Buat file konfigurasi Supabase di `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String supabaseUrl = 'your_supabase_url';
  static const String supabaseAnonKey = 'your_supabase_anon_key';
}
```

4. Jalankan aplikasi:

```bash
# Android
flutter run

# iOS
flutter run

# Web
flutter run -d chrome
```

---

## 🚀 Penggunaan

### Menjalankan Backend

```bash
# Development mode (auto-reload)
npm run dev

# Production mode
npm start

# Run tests
npm test

# Generate coverage report
npm run test:coverage
```

### Menjalankan Mobile App

```bash
# Check devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

### Akses API

API Backend tersedia di:

- Development: `http://localhost:3000`
- Production: `your-vercel-deployment.vercel.app`

Health check:

```bash
curl http://localhost:3000/health
```

---

## 📁 Struktur Proyek

### Backend Structure

```
backend/
├── api/                    # Vercel serverless entry point
│   └── index.js
├── src/
│   ├── app.js             # Express app configuration
│   ├── server.js          # Server entry point
│   ├── lib/               # Library & utilities
│   │   ├── supabase.js    # Supabase client
│   │   └── supabaseAdmin.js
│   ├── middlewares/       # Express middlewares
│   │   └── requireAuth.js
│   └── routes/            # API routes
│       ├── auth.routes.js
│       ├── income.routes.js
│       ├── expense.routes.js
│       ├── aspiration.routes.js
│       ├── event.routes.js
│       ├── broadcast.routes.js
│       └── admin.routes.js
├── tests/                 # Test files
│   ├── unit/             # Unit tests
│   └── integration/      # Integration tests
├── package.json
└── vercel.json           # Vercel deployment config
```

### Mobile Structure

```
mobile/
├── lib/
│   ├── main.dart         # App entry point
│   ├── core/             # Core utilities
│   │   ├── config/       # App configuration
│   │   ├── constants/    # Constants & strings
│   │   ├── providers/    # State providers
│   │   ├── routes/       # Navigation routes
│   │   └── theme/        # App theming
│   └── features/         # Feature modules
│       ├── auth/
│       ├── dashboard/
│       ├── aspirasi/
│       ├── marketplace/
│       ├── pemasukan/
│       ├── pengeluaran/
│       ├── laporan/
│       ├── aktivitas_dan_broadcast/
│       ├── data_rumah_dan_warga/
│       ├── verifikasi_warga/
│       ├── log_aktivitas/
│       └── profile/
├── assets/               # Images, fonts, etc.
├── test/                # Test files
├── pubspec.yaml         # Flutter dependencies
└── README.md
```

---

## 🧪 Testing

### Backend Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run unit tests only
npm run test:unit

# Run integration tests only
npm run test:integration

# Watch mode
npm run test:watch

# Test specific file
npm test -- tests/unit/middlewares/requireAuth.test.js
```

Coverage reports tersimpan di `backend/coverage/`.

### Mobile Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/widget_test.dart
```

---

## 👥 Tim Pengembang

Proyek ini dikembangkan oleh mahasiswa TI 3G Kelompok 1 - Semester 5:

| Nama                        | NIM        | Fitur yang Dikerjakan                                           |
| --------------------------- | ---------- | --------------------------------------------------------------- |
| **Aditya Atadewa**          | 2341720174 | • Authentication<br>• Marketplace<br>• Aspirasi dan Pesan Warga |
| **Ahmad Naufal Ilham**      | 2341720047 | • Pemasukan<br>• Warga: Keluarga<br>• Profil                    |
| **Aril Ibbet Ardana Putra** | 2341720095 | • Data Rumah & Warga<br>• Laporan Keuangan                      |
| **Chiko Abilla Basya**      | 2341720005 | • Pengeluaran<br>• Verifikasi Pengguna<br>• Log Aktivitas       |
| **Diana Rahmawati**         | 2341720162 | • Dashboard<br>• Kegiatan & Broadcast                           |

---

## 🤝 Contributing

Kontribusi sangat diterima! Untuk berkontribusi:

1. Fork repository ini
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

Pastikan kode mengikuti style guide dan lulus semua tests.

---

## 📝 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- **Politeknik Negeri Malang** - Institusi pendidikan
- **Supabase** - Backend infrastructure
- **Flutter Team** - Mobile framework
- **Express.js** - Backend framework

---

<div align="center">

**Dibuat dengan ❤️ oleh Tim Jawara Pintar**

_Kelompok 1 TI 3G - 2025_

</div>
