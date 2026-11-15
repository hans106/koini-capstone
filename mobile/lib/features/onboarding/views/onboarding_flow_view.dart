import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:koini/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:koini/features/onboarding/views/child_profile_setup_view.dart';
import 'package:koini/features/onboarding/views/initial_jar_split_view.dart';
import 'package:koini/features/onboarding/views/initial_settings_view.dart';
import 'package:koini/features/onboarding/views/parent_login_view.dart';
import 'package:koini/features/onboarding/views/ready_to_play_view.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<OnboardingViewModel, OnboardingFlowView>(
      (ref, view) => OnboardingViewModel(
        view.store,
        step: view.initialStep,
        name:
            view.demo && view.initialStep.index >= OnboardingStep.settings.index
            ? 'Raka'
            : '',
        pin: view.demo && view.initialStep.index >= OnboardingStep.split.index
            ? previewPin
            : '',
      ),
    );

class OnboardingFlowView extends ConsumerStatefulWidget {
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
  ConsumerState<OnboardingFlowView> createState() => _OnboardingFlowViewState();
}

class _OnboardingFlowViewState extends ConsumerState<OnboardingFlowView> {
  late final _provider = _viewModelProvider(widget);
  OnboardingViewModel get form => ref.read(_provider);
  late final TextEditingController name;
  late final TextEditingController allowance;
  late final TextEditingController limit;
  final email = TextEditingController();

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: form.name);
    allowance = TextEditingController(text: form.amount.toString());
    limit = TextEditingController(text: form.dailyLimit.toString());
  }

  @override
  void dispose() {
    name.dispose();
    allowance.dispose();
    limit.dispose();
    email.dispose();
    super.dispose();
  }

  void back() {
    if (form.back()) return;
    if (PreviewNavigation.maybeOf(context) != null) {
      Navigator.maybePop(context);
    } else {
      ref.read(authViewModelProvider.notifier).signOut();
    }
  }

  Future<void> next() async {
    FocusScope.of(context).unfocus();
    if (await form.next() && mounted) enterChildArea(context, widget.store);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) {
    final step = form.step.index;
    final titles = [
      'Persetujuan orang tua',
      'Profil anak',
      'Pengaturan awal',
      'Bagi uang saku',
      'Siap bermain',
    ];
    final actions = [
      'Lanjut',
      'Simpan profil',
      'Lanjut bagi uang saku',
      'Simpan rencana',
      'Mulai main',
    ];
    return PopScope(
      canPop: step == 0 && PreviewNavigation.maybeOf(context) != null,
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
              name: name,
            ).children(context),
            OnboardingStep.settings => InitialSettingsView(
              form: form,
              allowance: allowance,
              limit: limit,
              email: email,
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
