import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads Supabase and Google OAuth configuration from `--dart-define-from-file=env.json`.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  static bool get isConfigured =>
      url.isNotEmpty &&
      publishableKey.isNotEmpty &&
      !url.contains('your-project-ref') &&
      !publishableKey.contains('TEMPEL_PUBLISHABLE_KEY');

  static bool get hasGoogleClientId => googleWebClientId.isNotEmpty;

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<bool> initializeIfConfigured() async {
    if (_initialized) return true;
    if (!isConfigured) return false;
    await Supabase.initialize(url: url, publishableKey: publishableKey);
    _initialized = true;
    return true;
  }
}
