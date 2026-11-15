/// The account session is independent of the local parental PIN.
class AccountSession {
  const AccountSession();
}

abstract interface class AuthService {
  Future<AccountSession> signIn();
  Future<AccountSession> signUp();
  Future<void> signOut();
}

/// Simulates a session for the current process without credentials or I/O.
final class DemoAuthService implements AuthService {
  @override
  Future<AccountSession> signIn() async => const AccountSession();

  @override
  Future<AccountSession> signUp() async => const AccountSession();

  @override
  Future<void> signOut() async {}
}
