import 'package:flutter/material.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/onboarding/controllers/onboarding_controller.dart';
import 'package:koini/features/onboarding/views/child_profile_setup_view.dart';
import 'package:koini/features/onboarding/views/initial_jar_split_view.dart';
import 'package:koini/features/onboarding/views/initial_settings_view.dart';
import 'package:koini/features/onboarding/views/parent_login_view.dart';
import 'package:koini/features/onboarding/views/ready_to_play_view.dart';
import 'package:koini/services/koini_store.dart';

class OnboardingFlowView extends StatefulWidget {
  const OnboardingFlowView({
    super.key,
    required this.store,
    this.initialStep = OnboardingStep.login,
    this.demo = false,
  });
  final KoiniStore store;
  final OnboardingStep initialStep;
  final bool demo;

  @override
  State<OnboardingFlowView> createState() => _OnboardingFlowViewState();
}

class _OnboardingFlowViewState extends State<OnboardingFlowView> {
  late final form = OnboardingController(
    widget.store,
    step: widget.initialStep,
    demo: widget.demo,
  );

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  void back() {
    if (!form.back()) Navigator.pop(context);
  }

  Future<void> next() async {
    FocusScope.of(context).unfocus();
    if (await form.next() && mounted) enterChildArea(context, widget.store);
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: form, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) {
    final step = form.step.index;
    final titles = [
      'Masuk orang tua',
      'Profil anak',
      'Pengaturan awal',
      'Bagi uang saku',
      'Siap bermain',
    ];
    final actions = [
      'Masuk dalam mode demo',
      'Simpan profil',
      'Lanjut bagi uang saku',
      'Simpan rencana',
      'Mulai main',
    ];
    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (popped, _) {
        if (!popped && !form.busy) back();
      },
      child: KPage(
        title: step == 0 ? null : titles[step],
        leading: KBack(onTap: form.busy ? () {} : back),
        footer: KButton(
          actions[step],
          onTap: form.busy ? null : next,
          white: step == 0,
        ),
        children: [
          if (form.error != null) ...[
            Text(form.error!, style: const TextStyle(color: KColors.error)),
            const Gap(8),
          ],
          ...switch (form.step) {
            OnboardingStep.login => ParentLoginView(
              form: form,
            ).children(context),
            OnboardingStep.profile => ChildProfileSetupView(
              form: form,
            ).children(context),
            OnboardingStep.settings => InitialSettingsView(
              form: form,
            ).children(context),
            OnboardingStep.split => InitialJarSplitView(
              form: form,
            ).children(context),
            OnboardingStep.ready => ReadyToPlayView(
              form: form,
            ).children(context),
          },
        ],
      ),
    );
  }
}
