import 'package:flutter/material.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/app/launch_viewmodel.dart';
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
  late final model = LaunchViewModel(widget.store);

  @override
  void initState() {
    super.initState();
    model.load();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) {
      if (model.status == LaunchStatus.failed) {
        return KPage(
          title: 'Koini',
          back: false,
          footer: KButton('Coba lagi', onTap: model.load),
          children: [
            const KCallout(
              'Data belum bisa dibuka',
              'Coba buka kembali penyimpanan di HP ini.',
            ),
          ],
        );
      }
      if (model.status == LaunchStatus.loading) {
        return const SplashView();
      }
      return model.status == LaunchStatus.childArea
          ? ChildShell(store: widget.store)
          : WelcomeView(store: widget.store);
    },
  );
}
