import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Sky(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: .12, end: 1),
          curve: Curves.easeOutBack,
          duration: const Duration(milliseconds: 650),
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: const Mascot(glow: true),
        ),
      ),
    ),
  );
}

@Preview(name: 'Splash Koini', group: 'Onboarding', size: koiniPreviewSize)
Widget splashPreview() => KoiniPreviewHost(
  page: (context, store) => const SplashView(),
  scenario: PreviewScenario.newProfile,
);
