import 'package:google_sign_in/google_sign_in.dart';
import 'package:koini/services/auth_service.dart';
import 'package:koini/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Authenticates parents against Supabase Auth (Google Sign-In or Email).
final class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;
  static bool _googleInitialized = false;

  @override
  bool get isLiveBackend => true;

  @override
  AccountSession? get currentSession {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _sessionFromUser(user);
  }

  @override
  Future<AccountSession> signIn() => signInWithGoogle();

  @override
  Future<AccountSession> signUp() => signInWithGoogle();

  @override
  Future<AccountSession> signInWithGoogle() async {
    if (!SupabaseConfig.hasGoogleClientId) {
      throw const AuthFailure(
        'Login Google belum disetel. Isi GOOGLE_WEB_CLIENT_ID di env.json atau masuk dengan email.',
      );
    }
    try {
      final googleSignIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        await googleSignIn.initialize(
          serverClientId: SupabaseConfig.googleWebClientId,
        );
        _googleInitialized = true;
      }
      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthFailure(
          'Token Google tidak ditemukan. Periksa konfigurasi Google OAuth.',
        );
      }
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Login Google belum berhasil. Coba lagi.');
      }
      return _sessionFromUser(user);
    } on AuthFailure {
      rethrow;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('Login Google dibatalkan.');
      }
      throw const AuthFailure(
        'Login Google gagal. Pastikan SHA-1 dan Google OAuth sudah aktif.',
      );
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyAuthMessage(error.message));
    } catch (_) {
      throw const AuthFailure(
        'Tidak bisa terhubung ke Google. Periksa koneksi internet.',
      );
    }
  }

  @override
  Future<AccountSession> signInWithEmail(String email, String password) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || password.length < 6) {
      throw const AuthFailure(
        'Isi email yang valid dan kata sandi minimal 6 karakter.',
      );
    }
    try {
      final response = await _client.auth.signInWithPassword(
        email: trimmed,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Email atau kata sandi belum tepat.');
      }
      return _sessionFromUser(user);
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyAuthMessage(error.message));
    } catch (_) {
      throw const AuthFailure(
        'Gagal masuk. Periksa koneksi internet dan coba lagi.',
      );
    }
  }

  @override
  Future<AccountSession> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || password.length < 6) {
      throw const AuthFailure(
        'Isi email yang valid dan kata sandi minimal 6 karakter.',
      );
    }
    try {
      final response = await _client.auth.signUp(
        email: trimmed,
        password: password,
        data: (name != null && name.trim().isNotEmpty)
            ? {'full_name': name.trim()}
            : null,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Pendaftaran belum berhasil. Coba lagi.');
      }
      if (response.session == null) {
        throw const AuthFailure(
          'Akun dibuat! Cek kotak masuk emailmu untuk konfirmasi, lalu masuk kembali.',
        );
      }
      return _sessionFromUser(user);
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyAuthMessage(error.message));
    } catch (_) {
      throw const AuthFailure(
        'Gagal mendaftar. Periksa koneksi internet dan coba lagi.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (_googleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {
      // Ignore Google local sign-out failure when ending Supabase session.
    }
    await _client.auth.signOut();
  }

  AccountSession _sessionFromUser(User user) {
    final rawName =
        user.userMetadata?['full_name'] ?? user.userMetadata?['name'];
    return AccountSession(
      userId: user.id,
      email: user.email ?? '',
      displayName: rawName is String ? rawName : '',
      isDemo: false,
    );
  }

  String _friendlyAuthMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Email atau kata sandi belum tepat.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Periksa kotak masuk emailmu.';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'Email ini sudah terdaftar. Silakan masuk.';
    }
    if (lower.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    }
    return 'Gagal memproses akun. Periksa koneksi dan coba lagi.';
  }
}
