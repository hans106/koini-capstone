import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/features/jars/widgets/jar_split_editor.dart';
import 'package:koini/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:koini/features/onboarding/views/onboarding_flow_view.dart';
import 'package:koini/features/onboarding/views/welcome_view.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

class InitialJarSplitView {
  const InitialJarSplitView({required this.form});
  final OnboardingViewModel form;

  List<Widget> children(BuildContext context) => [
    JarSplitEditor(
      amount: form.amount,
      initial: form.split,
      period: form.period,
      onChanged: form.setSplit,
    ),
  ];
}

@Preview(
  name: 'Pembagian toples awal',
  group: 'Onboarding',
  size: koiniPreviewSize,
)
Widget initialJarSplitViewPreview() => KoiniPreviewHost(
  scenario: PreviewScenario.newProfile,
  page: (_, store) => OnboardingFlowView(
    store: store,
    initialStep: OnboardingStep.split,
    demo: true,
  ),
  returnPage: (_, store) => WelcomeView(store: store),
);
