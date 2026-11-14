import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/onboarding/controllers/onboarding_controller.dart';
import 'package:koini/features/onboarding/views/onboarding_flow_view.dart';
import 'package:koini/features/onboarding/views/welcome_view.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

class InitialSettingsView {
  const InitialSettingsView({required this.form});
  final OnboardingController form;

  List<Widget> children(BuildContext context) => [
    KCard(
      bright: true,
      child: Column(
        children: [
          KField(
            'Uang saku mingguan',
            form.allowance,
            numeric: true,
            onChanged: (_) => form.resetSplit(),
          ),
          const Gap(),
          KField('Batas jajan harian', form.limit, numeric: true),
        ],
      ),
    ),
    const Gap(),
    KField('Email orang tua (opsional)', form.email, email: true),
    const Gap(),
    KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('PIN rahasia Ayah/Bunda', size: 18),
          const Gap(8),
          PinDots(count: form.pin.length),
          const Gap(8),
          if (form.pin.length == 6) ...[
            caption('Ulangi PIN'),
            const Gap(5),
            PinDots(count: form.confirmation.length),
            const Gap(8),
          ],
          Keypad(pin: true, onDigit: form.enterPinDigit),
        ],
      ),
    ),
    const Gap(),
    KCard(
      padding: EdgeInsets.zero,
      child: SwitchListTile(
        title: const Text('Pengingat ringkasan mingguan'),
        subtitle: caption('Preferensi demo di perangkat'),
        value: form.reminders,
        onChanged: form.setReminders,
      ),
    ),
  ];
}

@Preview(name: 'Pengaturan awal', group: 'Onboarding', size: koiniPreviewSize)
Widget initialSettingsViewPreview() => KoiniPreviewHost(
  scenario: PreviewScenario.newProfile,
  page: (_, store) => OnboardingFlowView(
    store: store,
    initialStep: OnboardingStep.settings,
    demo: true,
  ),
  returnPage: (_, store) => WelcomeView(store: store),
);
