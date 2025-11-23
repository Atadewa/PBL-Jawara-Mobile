/// Konfigurasi API untuk seluruh aplikasi
/// File ini berisi base URL dan konfigurasi umum untuk API calls
class ApiConfig {
  // TODO: Ganti dengan base URL API production
  // Contoh: static const String baseUrl = 'https://api.jawara-pintar.com';
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // TODO: Set ke false saat menggunakan API real
  // Untuk development, gunakan dummy data dengan set true
  static const bool useDummyData = true;

  // Timeout untuk API calls
  static const Duration timeout = Duration(seconds: 30);

  // Headers default untuk semua request
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers dengan authorization token
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
