import 'package:flutter/material.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/onboarding/views/splash_view.dart';
import 'package:koini/features/onboarding/views/welcome_view.dart';
import 'package:koini/services/koini_store.dart';

class KoiniApp extends StatelessWidget {
  const KoiniApp({super.key, required this.store});
  final KoiniStore store;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Koini',
    debugShowCheckedModeBanner: false,
    theme: koiniTheme(),
    home: _Launch(store: store),
  );
}

class _Launch extends StatefulWidget {
  const _Launch({required this.store});
  final KoiniStore store;

  @override
  State<_Launch> createState() => _LaunchState();
}

class _LaunchState extends State<_Launch> {
  late Future<void> request = load();

  Future<void> load() async {
    await Future.wait([
      widget.store.load(),
      Future<void>.delayed(const Duration(milliseconds: 850)),
    ]);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: request,
    builder: (context, result) {
      if (result.hasError) {
        return KPage(
          title: 'Koini',
          back: false,
          footer: KButton(
            'Coba lagi',
            onTap: () => setState(() => request = load()),
          ),
          children: [
            const KCallout(
              'Data belum bisa dibuka',
              'Coba buka kembali penyimpanan di HP ini.',
            ),
          ],
        );
      }
      if (result.connectionState != ConnectionState.done) {
        return const SplashView();
      }
      return widget.store.hasProfile
          ? ChildShell(store: widget.store)
          : WelcomeView(store: widget.store);
    },
  );
}
