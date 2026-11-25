/// The account session is independent of the local parental PIN.
class AccountSession {
  const AccountSession({
    this.userId = 'demo',
    this.email = '',
    this.displayName = '',
    this.isDemo = true,
  });

  final String userId;
  final String email;
  final String displayName;
  final bool isDemo;
}

abstract interface class AuthService {
  AccountSession? get currentSession;
  bool get isLiveBackend;

  Future<AccountSession> signIn();
  Future<AccountSession> signUp();
  Future<AccountSession> signInWithGoogle();
  Future<AccountSession> signInWithEmail(String email, String password);
  Future<AccountSession> signUpWithEmail(
    String email,
    String password, {
    String? name,
  });
  Future<void> signOut();
}

/// Simulates a session for the current process without credentials or I/O.
final class DemoAuthService implements AuthService {
  AccountSession? _session;

  @override
  AccountSession? get currentSession => _session;

  @override
  bool get isLiveBackend => false;

  @override
  Future<AccountSession> signIn() async {
    _session = const AccountSession();
    return _session!;
  }

  @override
  Future<AccountSession> signUp() async {
    _session = const AccountSession();
    return _session!;
  }

  @override
  Future<AccountSession> signInWithGoogle() => signIn();

  @override
  Future<AccountSession> signInWithEmail(String email, String password) async {
    _session = AccountSession(email: email.trim());
    return _session!;
  }

  @override
  Future<AccountSession> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    _session = AccountSession(
      email: email.trim(),
      displayName: (name ?? '').trim(),
    );
    return _session!;
  }

  @override
  Future<void> signOut() async {
    _session = null;
  }
}
