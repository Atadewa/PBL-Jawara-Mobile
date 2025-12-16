/// Application configuration
/// Manages backend URLs and other config values
class AppConfig {
  /// Backend base URL - can be overridden via --dart-define BACKEND_URL
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://backend-jawara.vercel.app',
  );

  /// Supabase configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pqapkjxhlyuvvjqrnpys.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxYXBranhobHl1dnZqcXJucHlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyMjYwMzQsImV4cCI6MjA4MDgwMjAzNH0.yq9vvjb7zsWrih1xcNTT_skNjo5LMPSurrUJStn2lHE', 
  );
}
