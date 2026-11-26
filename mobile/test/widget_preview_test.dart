import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:koini/features/auth/views/login_view.dart';
import 'package:koini/features/auth/views/sign_up_view.dart';
import 'package:koini/features/dreams/views/create_dream_view.dart';
import 'package:koini/features/dreams/views/dream_detail_view.dart';
import 'package:koini/features/dreams/views/dream_list_view.dart';
import 'package:koini/features/home/views/home_view.dart';
import 'package:koini/features/home/views/weekly_summary_view.dart';
import 'package:koini/features/jars/views/jar_detail_view.dart';
import 'package:koini/features/jars/views/piggy_check_view.dart';
import 'package:koini/features/missions/mission_content.dart';
import 'package:koini/features/missions/views/koini_story_view.dart';
import 'package:koini/features/missions/views/mission_map_view.dart';
import 'package:koini/features/missions/views/mission_quiz_view.dart';
import 'package:koini/features/onboarding/views/child_profile_setup_view.dart';
import 'package:koini/features/onboarding/views/initial_jar_split_view.dart';
import 'package:koini/features/onboarding/views/initial_settings_view.dart';
import 'package:koini/features/onboarding/views/parent_login_view.dart';
import 'package:koini/features/onboarding/views/ready_to_play_view.dart';
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
import 'package:koini/features/plus/views/savings_bonus_view.dart';
import 'package:koini/features/plus/views/smart_plan_result_view.dart';
import 'package:koini/features/plus/views/smart_plan_view.dart';
import 'package:koini/features/rewards/views/badge_gallery_view.dart';
import 'package:koini/features/rewards/views/profile_view.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/features/transactions/views/structured_history_view.dart';
import 'package:koini/features/transactions/views/transaction_history_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

const allPreviews = <String, Widget Function()>{
  'loginPreview': loginPreview,
  'signUpPreview': signUpPreview,
  'createDreamPreview': createDreamPreview,
  'dreamDetailPreview': dreamDetailPreview,
  'dreamListPreview': dreamListPreview,
  'homePreview': homePreview,
  'emptyHomePreview': emptyHomePreview,
  'dreamHomePreview': dreamHomePreview,
  'completedHomePreview': completedHomePreview,
  'weeklySummaryPreview': weeklySummaryPreview,
  'tabungJarPreview': tabungJarPreview,
  'jajanJarPreview': jajanJarPreview,
  'berbagiJarPreview': berbagiJarPreview,
  'piggyCheckPreview': piggyCheckPreview,
  'storyPreview': storyPreview,
  'missionMapPreview': missionMapPreview,
  'completedMissionsPreview': completedMissionsPreview,
  'missionQuizPreview': missionQuizPreview,
  'childProfileSetupViewPreview': childProfileSetupViewPreview,
  'initialJarSplitViewPreview': initialJarSplitViewPreview,
  'initialSettingsViewPreview': initialSettingsViewPreview,
  'parentLoginViewPreview': parentLoginViewPreview,
  'readyToPlayViewPreview': readyToPlayViewPreview,
  'splashPreview': splashPreview,
  'welcomePreview': welcomePreview,
  'allowanceSettingsPreview': allowanceSettingsPreview,
  'changePinPreview': changePinPreview,
  'weeklyEmailPreview': weeklyEmailPreview,
  'alertEmailPreview': alertEmailPreview,
  'parentDashboardPreview': parentDashboardPreview,
  'parentPinPreview': parentPinPreview,
  'parentReportPreview': parentReportPreview,
  'monthlyReportPreview': monthlyReportPreview,
  'parentSettingsPreview': parentSettingsPreview,
  'activePlanPreview': activePlanPreview,
  'chooseDatedDreamPreview': chooseDatedDreamPreview,
  'datedGoalPreview': datedGoalPreview,
  'giftReleasePreview': giftReleasePreview,
  'giftSeasonPreview': giftSeasonPreview,
  'plusPackagesPreview': plusPackagesPreview,
  'rewardChallengePreview': rewardChallengePreview,
  'childRewardChallengePreview': childRewardChallengePreview,
  'savingsBonusPreview': savingsBonusPreview,
  'childSavingsBonusPreview': childSavingsBonusPreview,
  'smartPlanResultPreview': smartPlanResultPreview,
  'smartPlanPreview': smartPlanPreview,
  'badgeGalleryPreview': badgeGalleryPreview,
  'profilePreview': profilePreview,
  'transactionPreview': transactionPreview,
  'lowBalancePreview': lowBalancePreview,
  'structuredHistoryPreview': structuredHistoryPreview,
  'historyPreview': historyPreview,
};

Future<void> mount(WidgetTester tester, Widget Function() preview) async {
  await tester.binding.setSurfaceSize(koiniPreviewSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(home: preview()));
  await tester.pumpAndSettle();
}

Future<void> press(WidgetTester tester, String text) async {
  final control = find.text(text).hitTestable();
  expect(control, findsWidgets);
  await tester.tap(control.last);
  await tester.pumpAndSettle();
}

Future<void> enterPin(WidgetTester tester, String code, String submit) async {
  for (final digit in code.split('')) {
    await press(tester, digit);
  }
  await press(tester, submit);
}

void main() {
  for (final entry in allPreviews.entries) {
    testWidgets('${entry.key} renders the annotated widget', (tester) async {
      await mount(tester, entry.value);
      expect(find.byType(Scaffold), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  test(
    'preview stores start independently and do not share ledger writes',
    () async {
      final a = await createPreviewStore(PreviewScenario.normal);
      final b = await createPreviewStore(PreviewScenario.normal);
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      expect(
        await a.record(
          kind: EntryKind.income,
          amount: 10000,
          note: 'Preview',
          destination: Jar.jajan,
        ),
        isNull,
      );
      expect(a.balance(Jar.jajan), 55000);
      expect(b.balance(Jar.jajan), 45000);
    },
  );

  testWidgets(
    'account entry previews open onboarding with separate demo sessions',
    (tester) async {
      await mount(tester, loginPreview);
      await press(tester, 'Masuk dalam mode demo');
      expect(find.byType(CheckboxListTile), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await mount(tester, signUpPreview);
      expect(find.text('Daftar dalam mode demo'), findsOneWidget);
      await press(tester, 'Daftar dalam mode demo');
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('home cards and tabs use the normal app routes', (tester) async {
    await mount(tester, homePreview);
    await press(tester, 'Jajan');
    expect(find.text('Toples Jajan'), findsOneWidget);
    expect(find.text('Rp45.000'), findsWidgets);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    await press(tester, 'Impian');
    expect(find.text('Impian kamu'), findsOneWidget);
  });

  testWidgets('transaction preview validates funds and refreshes the ledger', (
    tester,
  ) async {
    await mount(tester, lowBalancePreview);
    await press(tester, '5');
    await press(tester, '000');
    await press(tester, 'Simpan');
    expect(find.text('Uang di toples Jajan tidak cukup.'), findsOneWidget);
    await press(tester, 'Ubah nominal');
    await press(tester, 'Uang masuk');
    await press(tester, 'Simpan');
    expect(find.text('Tersimpan!'), findsOneWidget);
    await press(tester, 'Selesai');
    expect(find.text('+Rp5.000'), findsWidgets);
  });

  testWidgets('dream preview updates estimate and creates a navigable dream', (
    tester,
  ) async {
    await mount(tester, createDreamPreview);
    final name = find.byType(TextField).first;
    final target = find.byType(TextField).last;
    await tester.enterText(name, 'Buku cerita');
    await tester.enterText(target, '120000');
    await tester.pumpAndSettle();
    expect(find.textContaining('12 minggu'), findsOneWidget);
    await tester.enterText(target, '240000');
    await tester.pumpAndSettle();
    expect(find.textContaining('24 minggu'), findsOneWidget);
    await press(tester, 'Simpan impian');
    await press(tester, 'Selesai');
    await press(tester, 'Buku cerita');
    expect(find.text('Jejak langkahmu'), findsOneWidget);
    expect(find.textContaining('Target Rp240.000'), findsOneWidget);
  });

  testWidgets(
    'quiz preview corrects an answer and reaches the mission result',
    (tester) async {
      await mount(tester, missionQuizPreview);
      final questions = missions
          .firstWhere((mission) => mission.id == 'butuh')
          .questions;
      await press(tester, questions.first.options[1]);
      expect(find.text('Belum tepat.'), findsOneWidget);
      await press(tester, 'Coba lagi');
      for (final question in questions) {
        await press(tester, question.options[question.correct]);
        await press(tester, 'Lanjut');
      }
      expect(find.text('Kamu makin pintar!'), findsOneWidget);
      expect(find.text('+12 bintang'), findsOneWidget);
    },
  );

  testWidgets('dream detail preview refreshes its progress after saving', (
    tester,
  ) async {
    await mount(tester, dreamDetailPreview);
    expect(find.textContaining('40%'), findsWidgets);
    await press(tester, 'Tambah tabungan');
    await press(tester, 'Uang tunai baru');
    for (final digit in ['1', '0', '0', '000']) {
      await press(tester, digit);
    }
    await press(tester, 'Simpan');
    expect(find.text('Tersimpan!'), findsOneWidget);
    await press(tester, 'Selesai');
    expect(find.textContaining('50%'), findsWidgets);
    expect(find.text('Rp500.000'), findsOneWidget);
  });

  testWidgets('PIN preview shows errors and opens editable parent settings', (
    tester,
  ) async {
    await mount(tester, parentPinPreview);
    await enterPin(tester, '000000', 'Buka ringkasan');
    expect(find.text('PIN belum tepat. Coba lagi, ya.'), findsOneWidget);
    await enterPin(tester, previewPin, 'Buka ringkasan');
    expect(find.text('Ringkasan orang tua'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -380));
    await tester.pumpAndSettle();
    await press(tester, 'Setelan orang tua');
    await press(tester, 'Simpan setelan');
    expect(find.text('Setelan orang tua tersimpan.'), findsOneWidget);
  });

  testWidgets(
    'Koini Plus preview activates a plan and opens structured history',
    (tester) async {
      await mount(tester, plusPackagesPreview);
      await press(tester, 'Bulanan');
      await press(tester, 'Mulai paket Bulanan');
      await press(tester, 'Aktifkan paket demo');
      expect(find.text('Koini Plus aktif!'), findsOneWidget);
      await press(tester, 'Catatan terstruktur');
      expect(find.text('Catatan terstruktur'), findsOneWidget);
    },
  );
}
