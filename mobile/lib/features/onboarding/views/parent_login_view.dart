import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/onboarding/controllers/onboarding_controller.dart';
import 'package:koini/features/onboarding/views/onboarding_flow_view.dart';
import 'package:koini/features/onboarding/views/welcome_view.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

class ParentLoginView {
  const ParentLoginView({required this.form});
  final OnboardingController form;

  List<Widget> children(BuildContext context) => [
    const Align(alignment: Alignment.centerRight, child: Mascot(size: 96)),
    heading('Untuk Ayah/Bunda', size: 28),
    const Gap(6),
    const Text('Masuk untuk mengawasi Koini.'),
    const Gap(13),
    const KCard(
      child: Text(
        'Gunakan akses demo lokal untuk mencoba pengaturan awal. '
        'Setelahnya, area orang tua dibuka dengan PIN 6 digit.',
      ),
    ),
    const Gap(),
    const Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        Pill('Hanya mencatat', color: KColors.mint),
        Pill('Tanpa iklan', color: KColors.mint),
        Pill('Tanpa uang sungguhan', color: KColors.mint),
      ],
    ),
    const Gap(14),
    KCard(
      bright: true,
      padding: EdgeInsets.zero,
      child: CheckboxListTile(
        value: form.consent,
        onChanged: (value) => form.setConsent(value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text(
          'Saya setuju Koini menyimpan data anak untuk pengawasan orang tua di HP ini.',
          style: TextStyle(fontSize: 13),
        ),
      ),
    ),
  ];
}

@Preview(name: 'Masuk orang tua', group: 'Onboarding', size: koiniPreviewSize)
Widget parentLoginViewPreview() => KoiniPreviewHost(
  scenario: PreviewScenario.newProfile,
  page: (_, store) => OnboardingFlowView(
    store: store,
    initialStep: OnboardingStep.login,
    demo: true,
  ),
  returnPage: (_, store) => WelcomeView(store: store),
);
