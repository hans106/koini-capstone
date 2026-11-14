import 'package:flutter/material.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/email_preview_view.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/views/parent_pin_view.dart';
import 'package:koini/features/parents/views/parent_report_view.dart';
import 'package:koini/features/plus/views/choose_dated_dream_view.dart';
import 'package:koini/features/plus/views/dated_goal_view.dart';
import 'package:koini/features/plus/views/gift_season_view.dart';
import 'package:koini/features/plus/views/plus_packages_view.dart';
import 'package:koini/features/plus/views/smart_plan_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

Future<T?> openPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

void plusGate(
  BuildContext context, {
  required bool yearly,
  VoidCallback? parentAccess,
}) {
  kSheet(
    context,
    yearly ? 'Fitur paket Tahunan' : 'Ini fitur Koini Plus',
    yearly
        ? 'Rapor, peringatan, target bertanggal, dan musim hadiah tersedia di paket Tahunan.'
        : 'Rencana Pintar dan Catatan terstruktur ada di Koini Plus. Fitur dasar Koini tetap gratis.',
    primary: parentAccess == null ? 'Oke' : 'Ajak Ayah/Bunda',
    secondary: parentAccess == null ? null : 'Nanti saja',
    action: parentAccess,
  );
}

void openSmartPlan(
  BuildContext context,
  KoiniStore store,
  Dream? dream, {
  VoidCallback? parentAccess,
}) {
  if (!store.hasPlus) {
    plusGate(context, yearly: false, parentAccess: parentAccess);
  } else {
    openPage(context, SmartPlanView(store: store, dream: dream));
  }
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
    openPage(context, DatedGoalView(store: store, dream: dream));
  }
}

void openYearly(BuildContext context, KoiniStore store, VoidCallback action) {
  if (store.hasYearly) {
    action();
  } else {
    plusGate(
      context,
      yearly: true,
      parentAccess: () => showPlus(context, store),
    );
  }
}

void showPlus(BuildContext context, KoiniStore store) => openPage(
  context,
  PlusPackagesView(
    store: store,
    yearlyFeatures: yearlyPlanActions(context, store),
  ),
);

Map<String, VoidCallback> yearlyPlanActions(
  BuildContext context,
  KoiniStore store,
) => {
  'Rapor bulanan': () =>
      openPage(context, ParentReportView(store: store, monthly: true)),
  'Peringatan email': () =>
      openPage(context, EmailPreviewView(store: store, alert: true)),
  'Target bertanggal': () => chooseDatedDream(context, store),
  'Musim uang hadiah': () => openPage(context, GiftSeasonView(store: store)),
};
Future<void> openParentArea(BuildContext context, KoiniStore store) async {
  final verified = await openPage<bool>(
    context,
    ParentPinView(
      title: 'PIN orang tua',
      prompt: 'Masukkan PIN 6 digit untuk membuka pengawasan di HP ini.',
      recovery: true,
      verify: (pin) async => store.checkPin(pin),
    ),
  );
  if (!context.mounted || verified != true) return;
  await openPage<void>(context, ParentDashboardView(store: store));
}

void chooseDatedDream(BuildContext context, KoiniStore store) {
  if (!store.dreams.any((dream) => store.remaining(dream) > 0)) {
    kSheet(
      context,
      'Belum ada impian aktif',
      'Buat impian di area anak untuk menetapkan tanggal.',
    );
    return;
  }
  openPage(context, ChooseDatedDreamView(store: store));
}

void enterChildArea(BuildContext context, KoiniStore store) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => ChildShell(store: store)),
    (_) => false,
  );
}
