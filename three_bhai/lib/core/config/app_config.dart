/// Build-time configuration, passed with:
///   flutter run --dart-define-from-file=env/dev.json
///
/// The Supabase URL and anon key are PUBLIC by design (data is protected by
/// Row Level Security). Secret keys (Spoonacular, Gemini) never live in the
/// app; they are Supabase Edge Function secrets, set once by the developer.
abstract final class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
