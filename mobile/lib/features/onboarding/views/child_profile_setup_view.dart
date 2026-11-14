import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/onboarding/controllers/onboarding_controller.dart';
import 'package:koini/features/onboarding/views/onboarding_flow_view.dart';
import 'package:koini/features/onboarding/views/welcome_view.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

class ChildProfileSetupView {
  const ChildProfileSetupView({required this.form});
  final OnboardingController form;

  List<Widget> children(BuildContext context) => [
    const Text('Buat profil anak yang akan dipakai di aplikasi.'),
    const Gap(17),
    const Center(child: Mascot(size: 125)),
    const Gap(5),
    caption('Avatar anak', align: TextAlign.center),
    const Gap(18),
    KField('Nama panggilan', form.name, hint: 'Raka', length: 24),
    const Gap(12),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        heading('Usia', size: 16),
        caption('${form.age} tahun', color: KColors.gold),
      ],
    ),
    const Gap(7),
    Wrap(
      spacing: 6,
      runSpacing: 7,
      children: [
        for (var option = 6; option <= 12; option++)
          Pill(
            '$option',
            selected: form.age == option,
            onTap: () => form.setAge(option),
          ),
      ],
    ),
    const Gap(15),
    const KCallout(
      'Kenalan dulu',
      'Nama panggilan dan usia membantu Koini menyesuaikan misi.',
    ),
  ];
}

@Preview(name: 'Buat profil anak', group: 'Onboarding', size: koiniPreviewSize)
Widget childProfileSetupViewPreview() => KoiniPreviewHost(
  scenario: PreviewScenario.newProfile,
  page: (_, store) => OnboardingFlowView(
    store: store,
    initialStep: OnboardingStep.profile,
    demo: true,
  ),
  returnPage: (_, store) => WelcomeView(store: store),
);
