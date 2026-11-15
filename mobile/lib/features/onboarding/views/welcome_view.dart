import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key, required this.store});
  final KoiniStore store;

  @override
  Widget build(BuildContext context) => KPage(
    back: false,
    footer: KButton('Mulai', onTap: () => welcomeStart(context)),
    children: [
      const Gap(7),
      const Center(child: Mascot(size: 160, glow: true)),
      const Gap(8),
      Center(
        child: Image.asset(
          'assets/images/wordmark.png',
          width: 130,
          semanticLabel: 'Koini',
        ),
      ),
      const Gap(2),
      const Text(
        'TEMAN PINTAR UANG SAKU',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
        ),
      ),
      const Gap(10),
      heading('Belajar menabung sejak dini', size: 22, align: TextAlign.center),
      caption(
        'Langkah kecil hari ini, impian besar nanti.',
        align: TextAlign.center,
      ),
      const Gap(14),
      const KRow(
        'Catat uang saku',
        'Tulis berapa uang saku yang kamu terima hari ini.',
        icon: Illustration('piggy', size: 39),
      ),
      const Gap(9),
      const KRow(
        'Wujudkan impian',
        'Pilih apa yang ingin kamu beli nanti.',
        icon: Illustration('bike', size: 39),
      ),
      const Gap(9),
      const KRow(
        'Misi harian',
        'Selesaikan tugas kecil untuk mendapat bintang.',
        icon: Icon(Icons.star, size: 39, color: KColors.gold),
      ),
      const Gap(14),
      caption(
        'Hanya mencatat · Tanpa uang sungguhan · Tanpa iklan',
        align: TextAlign.center,
      ),
    ],
  );
}

@Preview(name: 'Selamat datang', group: 'Onboarding', size: koiniPreviewSize)
Widget welcomePreview() => KoiniPreviewHost(
  page: (context, store) => WelcomeView(store: store),
  scenario: PreviewScenario.newProfile,
);
