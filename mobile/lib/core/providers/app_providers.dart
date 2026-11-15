import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koini/services/auth_service.dart';
import 'package:koini/services/koini_store.dart';

final koiniStoreProvider = Provider<KoiniStore>(
  (ref) =>
      throw StateError('Provide a KoiniStore in the app or preview scope.'),
);

final authServiceProvider = Provider<AuthService>((ref) => DemoAuthService());
