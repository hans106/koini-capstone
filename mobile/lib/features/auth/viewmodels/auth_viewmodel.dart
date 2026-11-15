import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koini/core/providers/app_providers.dart';
import 'package:koini/services/auth_service.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthState {
  const AuthState({this.session, this.busy = false, this.error});

  final AccountSession? session;
  final bool busy;
  final String? error;
  bool get signedIn => session != null;
}

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> signIn() => _authenticate(ref.read(authServiceProvider).signIn);
  Future<void> signUp() => _authenticate(ref.read(authServiceProvider).signUp);

  Future<void> _authenticate(Future<AccountSession> Function() action) async {
    if (state.busy || state.signedIn) return;
    state = const AuthState(busy: true);
    try {
      final session = await action();
      if (ref.mounted) state = AuthState(session: session);
    } catch (_) {
      if (ref.mounted) {
        state = const AuthState(error: 'Sesi demo belum dibuka. Coba lagi.');
      }
    }
  }

  Future<void> signOut() async {
    if (state.busy || !state.signedIn) return;
    final session = state.session;
    state = AuthState(session: session, busy: true);
    try {
      await ref.read(authServiceProvider).signOut();
      if (ref.mounted) state = const AuthState();
    } catch (_) {
      if (ref.mounted) {
        state = AuthState(
          session: session,
          error: 'Sesi belum ditutup. Coba lagi.',
        );
      }
    }
  }
}
