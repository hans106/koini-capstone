import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:koini/features/onboarding/views/onboarding_flow_view.dart';
import 'package:koini/features/onboarding/views/welcome_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

class InitialSettingsView {
  const InitialSettingsView({
    required this.form,
    required this.allowance,
    required this.limit,
    required this.email,
  });
  final OnboardingViewModel form;
  final TextEditingController allowance;
  final TextEditingController limit;
  final TextEditingController email;

  List<Widget> children(BuildContext context) => [
    KCard(
      bright: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          caption('Periode uang saku'),
          const Gap(6),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [
              for (final period in AllowancePeriod.values)
                Pill(
                  period.label,
                  selected: form.period == period,
                  onTap: () => form.setPeriod(period),
                ),
            ],
          ),
          const Gap(10),
          KField(
            'Uang saku ${form.period.label.toLowerCase()}',
            allowance,
            numeric: true,
            onChanged: form.changeAllowance,
          ),
          const Gap(),
          KField(
            'Batas jajan harian',
            limit,
            numeric: true,
            onChanged: form.changeLimit,
          ),
        ],
      ),
    ),
    const Gap(),
    KField(
      'Email orang tua (opsional)',
      email,
      email: true,
      onChanged: form.changeEmail,
    ),
    const Gap(),
    KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('PIN rahasia Ayah/Bunda', size: 18),
          const Gap(8),
          PinDots(count: form.pinLength),
          const Gap(8),
          if (form.pinLength == 6) ...[
            caption('Ulangi PIN'),
            const Gap(5),
            PinDots(count: form.confirmationLength),
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
