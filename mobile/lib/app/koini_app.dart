import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/providers/app_providers.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/services/auth_service.dart';
import 'package:koini/services/koini_store.dart';

class KoiniApp extends StatelessWidget {
  const KoiniApp({super.key, required this.store, this.authService});

  final KoiniStore store;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      koiniStoreProvider.overrideWithValue(store),
      if (authService case final service?)
        authServiceProvider.overrideWithValue(service),
    ],
    child: const _App(),
  );
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Koini',
    debugShowCheckedModeBanner: false,
    theme: koiniTheme(),
    routerConfig: ref.watch(routerProvider),
  );
}
