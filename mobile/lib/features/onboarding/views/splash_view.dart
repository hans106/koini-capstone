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
          builder: (_, scale, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(scale: scale, child: child),
              Opacity(
                opacity: ((scale - .7) / .3).clamp(0.0, 1.0),
                child: Column(
                  children: [
                    const Gap(10),
                    Image.asset(
                      'assets/images/wordmark.png',
                      width: 126,
                      semanticLabel: 'Koini',
                    ),
                    const Text(
                      'TEMAN PINTAR UANG SAKU',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child: const Mascot(size: 152, glow: true),
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
