import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/app/launch_viewmodel.dart';
import 'package:koini/core/providers/app_providers.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:koini/features/auth/views/login_view.dart';
import 'package:koini/features/auth/views/sign_up_view.dart';
import 'package:koini/features/dreams/views/create_dream_view.dart';
import 'package:koini/features/dreams/views/dream_detail_view.dart';
import 'package:koini/features/home/views/weekly_summary_view.dart';
import 'package:koini/features/jars/views/jar_detail_view.dart';
import 'package:koini/features/jars/views/piggy_check_view.dart';
import 'package:koini/features/missions/views/koini_story_view.dart';
import 'package:koini/features/missions/views/mission_quiz_view.dart';
import 'package:koini/features/onboarding/views/onboarding_flow_view.dart';
import 'package:koini/features/onboarding/views/splash_view.dart';
import 'package:koini/features/onboarding/views/welcome_view.dart';
import 'package:koini/features/parents/views/allowance_settings_view.dart';
import 'package:koini/features/parents/views/change_pin_view.dart';
import 'package:koini/features/parents/views/email_preview_view.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/views/parent_pin_view.dart';
import 'package:koini/features/parents/views/parent_report_view.dart';
import 'package:koini/features/parents/views/parent_settings_view.dart';
import 'package:koini/features/plus/views/active_plan_view.dart';
import 'package:koini/features/plus/views/choose_dated_dream_view.dart';
import 'package:koini/features/plus/views/dated_goal_view.dart';
import 'package:koini/features/plus/views/gift_release_view.dart';
import 'package:koini/features/plus/views/gift_season_view.dart';
import 'package:koini/features/plus/views/plus_packages_view.dart';
import 'package:koini/features/plus/views/reward_challenge_view.dart';
import 'package:koini/features/plus/views/smart_plan_result_view.dart';
import 'package:koini/features/plus/views/smart_plan_view.dart';
import 'package:koini/features/rewards/views/badge_gallery_view.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/features/transactions/views/structured_history_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

enum KRoute {
  login('/masuk'),
  signUp('/daftar'),
  welcome('/selamat-datang'),
  onboarding('/pengaturan-awal'),
  jar('/toples/:jar'),
  piggyCheck('/cek-celengan'),
  createDream('/impian/baru'),
  dream('/impian/:id'),
  transaction('/transaksi/baru'),
  structuredHistory('/transaksi/terstruktur'),
  weeklySummary('/ringkasan-mingguan'),
  quiz('/kuis/:id'),
  story('/cerita'),
  badges('/lencana'),
  celebration('/hasil'),
  parentPin('/pin-orang-tua'),
  parentDashboard('/orang-tua'),
  parentReport('/orang-tua/perkembangan'),
  monthlyReport('/orang-tua/rapor-bulanan'),
  parentSettings('/orang-tua/setelan'),
  allowance('/orang-tua/uang-saku'),
  changePin('/orang-tua/ganti-pin'),
  weeklyEmail('/orang-tua/email'),
  alertEmail('/orang-tua/peringatan'),
  plusPackages('/orang-tua/paket'),
  activePlan('/orang-tua/paket-aktif'),
  challenges('/tantangan-hadiah'),
  parentChallenges('/orang-tua/tantangan-hadiah'),
  chooseDatedDream('/orang-tua/pilih-target'),
  gifts('/orang-tua/hadiah'),
  releaseGift('/orang-tua/hadiah/pengembalian'),
  datedGoal('/target-bertanggal/:id'),
  smartPlan('/rencana-pintar'),
  smartPlanResult('/rencana-pintar/hasil');

  const KRoute(this.path);
  final String path;
}

typedef TransactionArgs = ({
  EntryKind kind,
  Dream? dream,
  Jar? source,
  Jar? destination,
});
typedef PlusPinArgs = ({Plan plan, Future<String?> Function(String) verify});
typedef SmartPlanResultArgs = ({Dream? dream, SmartPlan plan});

const _splash = '/splash';
const _child = 'child';
const _childHome = '/anak/home';
const _parentPinRequest = Object();

class _ParentAccess {
  bool opening = false;
  bool unlocked = false;
}

final _parentAccessProvider = Provider<_ParentAccess>((ref) => _ParentAccess());

final routerProvider = Provider<GoRouter>((ref) {
  final store = ref.watch(koiniStoreProvider);
  final parent = ref.read(_parentAccessProvider);
  final router = GoRouter(
    initialLocation: _splash,
    overridePlatformDefaultLocation: true,
    redirect: (context, state) {
      final path = state.uri.path;
      final startup = ref.read(launchProvider);
      if (startup.isLoading || startup.hasError) {
        return path == _splash ? null : _splash;
      }

      final onAccountPage =
          path == KRoute.login.path ||
          path == KRoute.signUp.path ||
          path == KRoute.welcome.path;
      if (!ref.read(authViewModelProvider).signedIn) {
        return onAccountPage ? null : KRoute.login.path;
      }
      if (!store.hasProfile) {
        return path == KRoute.onboarding.path ? null : KRoute.onboarding.path;
      }
      if (onAccountPage || path == _splash || path == KRoute.onboarding.path) {
        return _childHome;
      }

      final extra = state.extra;
      final requestsParent =
          path == KRoute.parentDashboard.path ||
          path.startsWith('${KRoute.parentDashboard.path}/') ||
          (extra is TransactionArgs && extra.kind == EntryKind.bonus);
      if (requestsParent && !parent.unlocked) return _childHome;
      if (path == KRoute.parentPin.path &&
          extra != _parentPinRequest &&
          !(parent.unlocked && extra is PlusPinArgs)) {
        return _childHome;
      }

      // Fitur yang dipotong dari MVP (smart_plan, dated_goal, email_preview, gift_season)
      // disembunyikan dari navigasi dan diarahkan kembali ke beranda anak.
      if (path == KRoute.smartPlan.path ||
          path == KRoute.smartPlanResult.path ||
          path == KRoute.chooseDatedDream.path ||
          path.startsWith('/target-bertanggal/') ||
          path == KRoute.weeklyEmail.path ||
          path == KRoute.alertEmail.path ||
          path.startsWith(KRoute.gifts.path)) {
        return _childHome;
      }

      if ((path == KRoute.structuredHistory.path ||
              path == KRoute.challenges.path ||
              path == KRoute.parentChallenges.path) &&
          !store.hasPlus) {
        return _childHome;
      }
      if (path == KRoute.monthlyReport.path && !store.hasYearly) {
        return _childHome;
      }
      return null;
    },
    routes: [
      GoRoute(path: _splash, builder: (_, _) => const _StartupPage()),
      GoRoute(
        name: _child,
        path: '/anak/:tab',
        redirect: (_, state) =>
            ChildTab.values.any(
              (tab) => tab.name == state.pathParameters['tab'],
            )
            ? null
            : _childHome,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: ChildShell(
            store: store,
            initialTab: ChildTab.values.byName(state.pathParameters['tab']!),
            onSelectTab: (context, tab) =>
                context.goNamed(_child, pathParameters: {'tab': tab.name}),
            onSignOut: ref.read(authViewModelProvider.notifier).signOut,
          ),
        ),
      ),
      for (final route in KRoute.values)
        GoRoute(
          name: route.name,
          path: route.path,
          pageBuilder: (context, state) => MaterialPage<Object?>(
            key: state.pageKey,
            child: Builder(
              builder: (context) => _screen(
                context,
                store,
                route,
                state.pathParameters,
                state.extra,
              ),
            ),
          ),
        ),
    ],
    errorBuilder: (context, _) => KPage(
      title: 'Halaman tidak tersedia',
      back: false,
      footer: KButton('Beranda', onTap: () => context.go(_childHome)),
      children: const [],
    ),
  );
  ref.listen(launchProvider, (_, _) => router.refresh());
  ref.listen(authViewModelProvider.select((state) => state.signedIn), (
    _,
    signedIn,
  ) {
    if (!signedIn) parent.unlocked = false;
    router.refresh();
  });
  ref.onDispose(router.dispose);
  return router;
});

class _StartupPage extends ConsumerWidget {
  const _StartupPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(launchProvider).hasError) return const SplashView();
    return KPage(
      title: 'Koini',
      back: false,
      footer: KButton('Coba lagi', onTap: () => ref.invalidate(launchProvider)),
      children: const [
        KCallout(
          'Data belum bisa dibuka',
          'Coba buka kembali penyimpanan di HP ini.',
        ),
      ],
    );
  }
}

Widget _screen(
  BuildContext context,
  KoiniStore store,
  KRoute route,
  Map<String, String> params,
  Object? extra,
) {
  void parentAccess() => openParentArea(context);
  final dream = store.dreams
      .where((item) => item.id == params['id'])
      .firstOrNull;
  final jar = Jar.values
      .where((item) => item.name == params['jar'])
      .firstOrNull;
  final mission = store.catalogMissions
      .where((item) => item.id == params['id'])
      .firstOrNull;
  final transaction = extra is TransactionArgs ? extra : null;
  return switch (route) {
    KRoute.login => const LoginView(),
    KRoute.signUp => const SignUpView(),
    KRoute.welcome => WelcomeView(store: store),
    KRoute.onboarding => OnboardingFlowView(store: store),
    KRoute.jar when jar != null => JarDetailView(store: store, jar: jar),
    KRoute.piggyCheck => PiggyCheckView(store: store),
    KRoute.createDream => CreateDreamView(store: store),
    KRoute.dream when dream != null => DreamDetailView(
      store: store,
      id: dream.id,
      parentAccess: parentAccess,
    ),
    KRoute.transaction => AddTransactionView(
      store: store,
      kind: transaction?.kind ?? EntryKind.spend,
      dream: transaction?.dream,
      source: transaction?.source,
      destination: transaction?.destination,
    ),
    KRoute.structuredHistory => StructuredHistoryView(
      store: store,
      readOnly: extra == true,
    ),
    KRoute.weeklySummary => WeeklySummaryView(store: store),
    KRoute.quiz when mission != null => MissionQuizView(
      store: store,
      mission: mission,
    ),
    KRoute.story => KoiniStoryView(store: store, parentAccess: parentAccess),
    KRoute.badges => BadgeGalleryView(store: store),
    KRoute.celebration when extra is Celebration => extra,
    KRoute.parentPin when extra is PlusPinArgs => ParentPinView(
      title: 'PIN Ayah/Bunda',
      prompt: 'Masukkan PIN 6 angka untuk memilih paket ${extra.plan.label}.',
      buttonLabel: 'Aktifkan paket demo',
      verify: extra.verify,
    ),
    KRoute.parentPin => ParentPinView(
      title: 'PIN orang tua',
      prompt: 'Masukkan PIN 6 digit untuk membuka pengawasan di HP ini.',
      recovery: true,
      verify: (pin) async => store.checkPin(pin),
    ),
    KRoute.parentDashboard => ParentDashboardView(store: store),
    KRoute.parentReport || KRoute.monthlyReport => ParentReportView(
      store: store,
      monthly: route == KRoute.monthlyReport,
    ),
    KRoute.parentSettings => ParentSettingsView(store: store),
    KRoute.allowance => AllowanceSettingsView(store: store),
    KRoute.changePin => ChangePinView(store: store),
    KRoute.weeklyEmail || KRoute.alertEmail => EmailPreviewView(
      store: store,
      alert: route == KRoute.alertEmail,
    ),
    KRoute.plusPackages => PlusPackagesView(
      store: store,
      yearlyFeatures: yearlyPlanActions(context, store),
    ),
    KRoute.activePlan => ActivePlanView(
      store: store,
      yearlyFeatures: yearlyPlanActions(context, store),
    ),
    KRoute.challenges => RewardChallengeView(store: store),
    KRoute.parentChallenges => RewardChallengeView(
      store: store,
      parentMode: true,
    ),
    KRoute.chooseDatedDream => ChooseDatedDreamView(store: store),
    KRoute.gifts => GiftSeasonView(store: store),
    KRoute.releaseGift => GiftReleaseView(store: store),
    KRoute.datedGoal when dream != null => DatedGoalView(
      store: store,
      dream: dream,
    ),
    KRoute.smartPlan => SmartPlanView(
      store: store,
      dream: extra is Dream ? extra : null,
    ),
    KRoute.smartPlanResult when extra is SmartPlanResultArgs =>
      SmartPlanResultView(store: store, dream: extra.dream, plan: extra.plan),
    _ => KPage(
      title: 'Halaman tidak tersedia',
      footer: KButton(
        'Kembali',
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            GoRouter.maybeOf(context)?.go(_childHome);
          }
        },
      ),
      children: const [],
    ),
  };
}

/// Each Widget Preview uses its own Navigator and in-memory store.
class PreviewNavigation extends InheritedWidget {
  const PreviewNavigation({
    super.key,
    required this.store,
    required super.child,
  });

  final KoiniStore store;

  static PreviewNavigation? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PreviewNavigation>();

  @override
  bool updateShouldNotify(PreviewNavigation oldWidget) =>
      store != oldWidget.store;
}

Future<T?> openPage<T>(
  BuildContext context,
  KRoute route, {
  Map<String, String> pathParameters = const {},
  Object? extra,
}) {
  if (PreviewNavigation.maybeOf(context) case final preview?) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (context) =>
            _screen(context, preview.store, route, pathParameters, extra),
      ),
    );
  }
  return context.pushNamed<T>(
    route.name,
    pathParameters: pathParameters,
    extra: extra,
  );
}

void returnToLogin(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    GoRouter.maybeOf(context)?.goNamed(KRoute.login.name);
  }
}

void continueAfterDemoAuth(BuildContext context) {
  // App entry is redirected by the session provider. A preview pushes locally.
  if (PreviewNavigation.maybeOf(context) case final preview?) {
    if (preview.store.hasProfile) {
      enterChildArea(context, preview.store);
    } else {
      openPage(context, KRoute.onboarding);
    }
  }
}

void welcomeStart(BuildContext context) {
  if (PreviewNavigation.maybeOf(context) != null) {
    openPage(context, KRoute.onboarding);
  } else {
    returnToLogin(context);
  }
}

Future<void> openParentArea(BuildContext context) async {
  final access = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(_parentAccessProvider);
  if (access.opening) return;
  access.opening = true;
  try {
    final verified = await openPage<bool>(
      context,
      KRoute.parentPin,
      extra: _parentPinRequest,
    );
    if (!context.mounted || verified != true) return;
    access.unlocked = true;
    await openPage<void>(context, KRoute.parentDashboard);
  } finally {
    access.unlocked = false;
    access.opening = false;
  }
}

void enterChildArea(BuildContext context, KoiniStore store) {
  if (PreviewNavigation.maybeOf(context) != null) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => ChildShell(store: store)),
      (_) => false,
    );
  } else {
    context.go(_childHome);
  }
}

void plusGate(
  BuildContext context, {
  required bool yearly,
  VoidCallback? parentAccess,
}) {
  kSheet(
    context,
    yearly ? 'Fitur paket Tahunan' : 'Ini fitur Koini Plus',
    yearly ? 'Rapor bulanan tersedia di paket Tahunan.' : 'Catatan terstruktur ada di Koini Plus. Fitur dasar Koini tetap gratis.',
    primary: parentAccess == null ? 'Oke' : 'Ajak Ayah/Bunda',
    secondary: parentAccess == null ? null : 'Nanti saja',
    action: parentAccess,
  );
}

void openDatedGoal(
  BuildContext context,
  KoiniStore store,
  Dream dream, {
  VoidCallback? parentAccess,
}) {
  if (!store.hasYearly) {
    plusGate(context, yearly: true, parentAccess: parentAccess);
  } else {
    openPage(context, KRoute.datedGoal, pathParameters: {'id': dream.id});
  }
}

void openYearly(BuildContext context, KoiniStore store, VoidCallback action) {
  if (store.hasYearly) {
    action();
  } else {
    plusGate(context, yearly: true, parentAccess: () => showPlus(context));
  }
}

void showPlus(BuildContext context) => openPage(context, KRoute.plusPackages);

Map<String, VoidCallback> yearlyPlanActions(
  BuildContext context,
  KoiniStore store,
) => {'Rapor bulanan': () => openPage(context, KRoute.monthlyReport)};
