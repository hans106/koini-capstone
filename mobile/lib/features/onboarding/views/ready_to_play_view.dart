import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/onboarding/controllers/onboarding_controller.dart';
import 'package:koini/features/onboarding/views/onboarding_flow_view.dart';
import 'package:koini/features/onboarding/views/welcome_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

class ReadyToPlayView {
  const ReadyToPlayView({required this.form});
  final OnboardingController form;

  List<Widget> children(BuildContext context) => [
    const Gap(20),
    caption(
      '3 dari 3 langkah selesai',
      color: KColors.mint,
      align: TextAlign.center,
    ),
    const Gap(22),
    const Center(child: Mascot(glow: true, size: 155)),
    const Gap(17),
    heading(
      'Semua sudah siap.',
      size: 32,
      color: KColors.gold,
      align: TextAlign.center,
    ),
    caption(
      'Ayah/Bunda, serahkan HP ke ${form.name.text.trim()}.',
      align: TextAlign.center,
    ),
    const Gap(23),
    KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          caption('Uang saku mingguan'),
          heading(rupiah(form.amount)),
          const Gap(8),
          caption('Batas jajan harian'),
          heading(rupiah(form.dailyLimit), size: 18, color: KColors.peach),
          const Gap(8),
          caption('Keamanan'),
          heading(
            'PIN 6 angka khusus Ayah/Bunda',
            size: 16,
            color: KColors.mint,
          ),
        ],
      ),
    ),
  ];
}

@Preview(name: 'Siap bermain', group: 'Onboarding', size: koiniPreviewSize)
Widget readyToPlayViewPreview() => KoiniPreviewHost(
  scenario: PreviewScenario.newProfile,
  page: (_, store) => OnboardingFlowView(
    store: store,
    initialStep: OnboardingStep.ready,
    demo: true,
  ),
  returnPage: (_, store) => WelcomeView(store: store),
);
