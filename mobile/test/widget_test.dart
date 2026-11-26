import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:koini/app/koini_app.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/features/auth/views/login_view.dart';
import 'package:koini/features/auth/views/sign_up_view.dart';
import 'package:koini/features/dreams/views/create_dream_view.dart';
import 'package:koini/features/dreams/views/dream_detail_view.dart';
import 'package:koini/features/home/views/weekly_summary_view.dart';
import 'package:koini/features/jars/views/jar_detail_view.dart';
import 'package:koini/features/missions/mission_content.dart';
import 'package:koini/features/missions/views/koini_story_view.dart';
import 'package:koini/features/onboarding/views/splash_view.dart';
import 'package:koini/features/parents/views/allowance_settings_view.dart';
import 'package:koini/features/parents/views/change_pin_view.dart';
import 'package:koini/features/parents/views/email_preview_view.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/views/parent_report_view.dart';
import 'package:koini/features/parents/views/parent_settings_view.dart';
import 'package:koini/features/plus/views/dated_goal_view.dart';
import 'package:koini/features/plus/views/gift_release_view.dart';
import 'package:koini/features/plus/views/gift_season_view.dart';
import 'package:koini/features/plus/views/plus_packages_view.dart';
import 'package:koini/features/plus/views/smart_plan_view.dart';
import 'package:koini/features/rewards/views/badge_gallery_view.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/features/transactions/views/structured_history_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

import 'koini_store_test.dart' show MemoryStorage, createProfile;

Future<void> start(
  WidgetTester tester,
  KoiniStore store, {
  bool signIn = true,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(KoiniApp(store: store));
  await tester.pump();
  expect(find.byType(SplashView), findsOneWidget);
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  expect(find.byType(LoginView), findsOneWidget);
  if (signIn) await tap(tester, 'Masuk dalam mode demo');
}

Future<void> tap(WidgetTester tester, String label) async {
  final found = find.text(label).hitTestable();
  expect(
    found,
    findsWidgets,
    reason: 'Expected a visible control labeled $label',
  );
  await tester.tap(found.last);
  await tester.pumpAndSettle();
}

Future<void> pin(
  WidgetTester tester,
  String code, {
  String button = 'Buka ringkasan',
}) async {
  for (final digit in code.split('')) {
    await tap(tester, digit);
  }
  await tap(tester, button);
}

void main() {
  testWidgets('onboarding requires consent and saves a new local profile', (
    tester,
  ) async {
    final store = KoiniStore(MemoryStorage());
    await start(tester, store, signIn: false);
    await tap(tester, 'Belum punya akun? Daftar');
    expect(find.byType(SignUpView), findsOneWidget);
    await tap(tester, 'Daftar dalam mode demo');
    await tap(tester, 'Lanjut');
    expect(
      find.text('Centang persetujuan orang tua untuk melanjutkan.'),
      findsOneWidget,
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tap(tester, 'Lanjut');
    await tester.enterText(find.byType(TextField).first, 'Raka');
    await tap(tester, 'Simpan profil');
    for (final digit in '123456123456'.split('')) {
      final key = find.text(digit).last;
      await tester.ensureVisible(key);
      await tap(tester, digit);
    }
    await tap(tester, 'Lanjut bagi uang saku');
    await tap(tester, 'Simpan rencana');
    await tap(tester, 'Mulai main');
    expect(find.text('Hai, Raka!'), findsOneWidget);
    expect(store.total, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('child tabs and PIN-protected parent routes', (tester) async {
    final store = KoiniStore(MemoryStorage());
    await createProfile(store);
    await store.receiveAllowance();
    await store.addDream('Sepeda baru', 1, 1000000, 40000);
    final dream = store.dreams.single;
    await store.record(
      kind: EntryKind.save,
      amount: 350000,
      note: '',
      dream: dream,
    );
    await start(tester, store);

    expect(find.text('35% tercapai · Kurang Rp650.000'), findsOneWidget);
    await tap(tester, 'Impian');
    await tap(tester, 'Sepeda baru');
    expect(find.text('Jejak langkahmu'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    await tap(tester, 'Catat');
    expect(find.text('Catatan uangku'), findsOneWidget);
    await tap(tester, 'Misi');
    expect(find.text('Peta misi'), findsOneWidget);
    await tap(tester, 'Profil');
    await tap(tester, 'Akses orang tua');
    await pin(tester, '000000');
    expect(find.text('PIN belum tepat. Coba lagi, ya.'), findsOneWidget);
    await pin(tester, '123456');
    expect(find.text('Ringkasan orang tua'), findsOneWidget);
    await tap(tester, 'Koini Plus');
    await tap(tester, 'Tahunan');
    await tap(tester, 'Mulai paket Tahunan');
    await tap(tester, 'Aktifkan paket demo');
    expect(find.text('Koini Plus aktif!'), findsOneWidget);
    expect(store.plan, Plan.yearly);
    await tap(tester, 'Kembali ke Ringkasan');
    final exit = find.text('Keluar ke profil anak');
    await tester.ensureVisible(exit);
    await tap(tester, 'Keluar ke profil anak');
    await tap(tester, 'Akses orang tua');
    expect(find.text('PIN orang tua'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cold launch and sign-out keep local data behind demo login', (
    tester,
  ) async {
    final storage = MemoryStorage();
    final store = KoiniStore(storage);
    await createProfile(store);
    await store.receiveAllowance();
    await store.record(kind: EntryKind.spend, amount: 5000, note: 'Roti');

    await start(tester, store);
    expect(find.text('Total tiga toples Rp95.000'), findsOneWidget);
    await tap(tester, 'Profil');
    final logout = find.text('Keluar dari mode demo');
    await tester.ensureVisible(logout);
    await tap(tester, 'Keluar dari mode demo');
    expect(find.byType(LoginView), findsOneWidget);
    expect(store.total, 95000);

    await tap(tester, 'Masuk dalam mode demo');
    expect(find.text('Hai, Raka!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    final reopened = KoiniStore(storage);
    await start(tester, reopened, signIn: false);
    expect(find.text('Hai, Raka!'), findsNothing);
    await tap(tester, 'Masuk dalam mode demo');
    expect(find.text('Total tiga toples Rp95.000'), findsOneWidget);
    expect(reopened.entries.first.note, 'Roti');
    expect(reopened.checkPin('123456'), isNull);
  });

  testWidgets('router guards parent deep links before PIN and after Back', (
    tester,
  ) async {
    final store = KoiniStore(MemoryStorage());
    await createProfile(store);
    await start(tester, store, signIn: false);
    final router = GoRouter.of(tester.element(find.byType(LoginView)));
    router.go('/orang-tua/setelan');
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);

    await tap(tester, 'Masuk dalam mode demo');
    for (final path in [
      '/orang-tua',
      '/orang-tua/setelan',
      '/orang-tua/perkembangan',
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.text('Hai, Raka!'), findsOneWidget);
      expect(find.byType(ParentDashboardView), findsNothing);
      expect(find.byType(ParentSettingsView), findsNothing);
      expect(find.byType(ParentReportView), findsNothing);
    }
    await tap(tester, 'Atur');
    await pin(tester, '123456');
    expect(find.byType(ParentDashboardView), findsOneWidget);
    await tap(tester, 'Detail perkembangan');
    expect(find.byType(ParentReportView), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ParentDashboardView), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    router.go('/orang-tua/setelan');
    await tester.pumpAndSettle();
    expect(find.text('Hai, Raka!'), findsOneWidget);
    expect(find.byType(ParentSettingsView), findsNothing);
  });

  testWidgets('quiz feedback advances five questions and awards stars', (
    tester,
  ) async {
    final store = KoiniStore(MemoryStorage());
    await createProfile(store);
    await start(tester, store);
    await tap(tester, 'Misi');
    await tap(tester, 'Main misi');
    final questions = missions.first.questions;
    await tap(tester, questions.first.options.first);
    expect(find.text('Belum tepat.'), findsOneWidget);
    await tap(tester, 'Coba lagi');
    for (final question in questions) {
      await tap(tester, question.options[question.correct]);
      await tap(tester, 'Lanjut');
    }
    expect(find.text('Kamu makin pintar!'), findsOneWidget);
    expect(store.stars, 12);
    expect(tester.takeException(), isNull);
  });
  testWidgets('secondary screens lay out on a narrow Android viewport', (
    tester,
  ) async {
    final store = KoiniStore(MemoryStorage());
    await createProfile(store);
    await store.receiveAllowance();
    await store.addDream('Sepeda baru', 1, 1000000, 40000);
    final dream = store.dreams.single;
    await store.record(
      kind: EntryKind.save,
      amount: 350000,
      note: '',
      dream: dream,
    );
    await store.record(
      kind: EntryKind.spend,
      amount: 5000,
      note: 'Roti',
      category: 'Makanan',
    );
    await store.activatePlan(Plan.yearly, '123456');
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final screens = <Widget>[
      const LoginView(),
      const SignUpView(),
      JarDetailView(store: store, jar: Jar.tabung),
      WeeklySummaryView(store: store),
      AddTransactionView(store: store, kind: EntryKind.save, dream: dream),
      AddTransactionView(store: store, kind: EntryKind.transfer),
      CreateDreamView(store: store),
      DreamDetailView(store: store, id: dream.id),
      BadgeGalleryView(store: store),
      KoiniStoryView(store: store, parentAccess: () {}),
      ParentDashboardView(store: store),
      ParentReportView(store: store),
      ParentReportView(store: store, monthly: true),
      ParentSettingsView(store: store),
      AllowanceSettingsView(store: store),
      ChangePinView(store: store),
      EmailPreviewView(store: store),
      EmailPreviewView(store: store, alert: true),
      GiftSeasonView(store: store),
      GiftReleaseView(store: store),
      PlusPackagesView(store: store, yearlyFeatures: const {}),
      SmartPlanView(store: store, dream: dream),
      DatedGoalView(store: store, dream: dream),
      StructuredHistoryView(store: store),
    ];
    for (var i = 0; i < screens.length; i++) {
      final screen = screens[i];
      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey(i),
          child: MaterialApp(theme: koiniTheme(), home: screen),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '${screen.runtimeType}');
      if (find.byType(ListView).evaluate().isNotEmpty) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -410));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.runtimeType} after scrolling',
        );
      }
    }
  });
}
