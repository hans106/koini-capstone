import 'dart:math';
import 'dart:typed_data';

import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/features/parents/services/report_pdf.dart';
import 'package:koini/features/parents/widgets/period_widgets.dart';
import 'package:koini/features/rewards/viewmodels/badge_progress.dart';
import 'package:koini/models/badge.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class ParentOverviewViewModel extends StoreViewModel {
  ParentOverviewViewModel(
    this._store, {
    this.monthly = false,
    this.alert = false,
  }) : super(_store);
  final KoiniStore _store;
  final bool monthly;
  final bool alert;

  String get child => _store.name;
  String get recipient => _store.email.isEmpty ? 'Ayah/Bunda' : _store.email;
  DateTime get today => _store.now;
  DateTime get periodStart =>
      monthly ? DateTime(today.year, today.month) : weekStart(today);
  List<MoneyEntry> get entries => monthly ? _store.thisMonth : _store.thisWeek;
  Dream? get dream => _store.activeDream;
  Plan get plan => _store.plan;
  int get savings => _store.netSavings(entries);
  int get spent => _store.amountFor(EntryKind.spend, entries);
  int get emailAmount => alert ? _store.balance(Jar.tabung) : savings;
  bool get alerts => _store.alerts;
  String get missionFraction =>
      '${_store.scores.length}/${_store.catalogMissions.length}';
  int get weeklyChange {
    final previous = periodStart.subtract(const Duration(days: 7));
    return savings -
        _store.netSavings(
          _store.entries.where(
            (entry) =>
                !entry.date.isBefore(previous) &&
                entry.date.isBefore(periodStart),
          ),
        );
  }

  int get _plannedReceipts {
    if (!monthly) return 1;
    final firstMonday = (DateTime.monday - periodStart.weekday) % 7 + 1;
    return today.day < firstMonday ? 0 : 1 + (today.day - firstMonday) ~/ 7;
  }

  Map<Jar, ({int planned, int actual})> get jarReport {
    final period = entries;
    return {
      for (final jar in Jar.values)
        jar: (
          planned: _store.split[jar]! * _plannedReceipts,
          actual: switch (jar) {
            Jar.tabung => _store.netSavings(period),
            Jar.jajan => _store.amountFor(EntryKind.spend, period),
            Jar.berbagi => _store.amountFor(EntryKind.give, period),
          },
        ),
    };
  }

  Map<Jar, int> _amounts(Iterable<MoneyEntry> items) => {
    Jar.tabung: max(0, _store.netSavings(items)),
    Jar.jajan: _store.amountFor(EntryKind.spend, items),
    Jar.berbagi: _store.amountFor(EntryKind.give, items),
  };

  /// Mingguan: satu kelompok per hari. Bulanan: satu kelompok per minggu.
  List<ChartBucket> get buckets {
    final items = entries;
    if (!monthly) {
      const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      return [
        for (var i = 0; i < 7; i++)
          (
            label: names[i],
            amounts: _amounts(
              items.where(
                (entry) =>
                    dayStart(entry.date) ==
                    DateTime(
                      periodStart.year,
                      periodStart.month,
                      periodStart.day + i,
                    ),
              ),
            ),
          ),
      ];
    }
    final days = DateTime(periodStart.year, periodStart.month + 1, 0).day;
    final offset = periodStart.weekday - 1;
    final weeks = (days + offset + 6) ~/ 7;
    return [
      for (var week = 0; week < weeks; week++)
        (
          label: 'M${week + 1}',
          amounts: _amounts(
            items.where((entry) => (entry.date.day - 1 + offset) ~/ 7 == week),
          ),
        ),
    ];
  }

  /// Riwayat periode ini, dikelompokkan per hari (terbaru di atas).
  List<DayGroup> get history {
    final groups = <DateTime, List<MoneyEntry>>{};
    for (final entry in entries) {
      groups.putIfAbsent(dayStart(entry.date), () => []).add(entry);
    }
    final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return [for (final day in days) (day: day, items: groups[day]!)];
  }

  Iterable<MoneyEntry> _byKind(EntryKind kind) =>
      entries.where((entry) => entry.kind == kind);
  int get challengeCount => _byKind(EntryKind.challengeReward).length;
  int get challengeRewards =>
      _byKind(EntryKind.challengeReward)
          .fold(0, (sum, entry) => sum + entry.amount);
  int get bonusRewards =>
      _byKind(EntryKind.bonus).fold(0, (sum, entry) => sum + entry.amount);

  Iterable<({String name, String result})> get completedMissions sync* {
    final scores = _store.scores;
    for (final mission in _store.catalogMissions) {
      final score = scores[mission.id];
      if (score != null) {
        yield (
          name: mission.name,
          result: '$score/5 benar · ${score * 3} bintang',
        );
      }
    }
  }

  Iterable<KoiniBadge> get earnedBadges =>
      badges(_store).where((badge) => badge.earned);
  int savedFor(Dream dream) => _store.savedFor(dream);
  double progress(Dream dream) => _store.progress(dream);

  ReportPdfData get pdfData => ReportPdfData(
    child: child,
    periodStart: periodStart,
    generatedAt: today,
    jars: jarReport,
    savings: savings,
    missions: missionFraction,
    challengeCount: challengeCount,
    challengeRewards: challengeRewards,
    bonusRewards: bonusRewards,
    badges: [for (final badge in earnedBadges) badge.name],
    history: [...entries]..sort((a, b) => a.date.compareTo(b.date)),
  );

  /// Membuat PDF lalu menyerahkannya ke [share] (lembar bagikan/simpan).
  Future<bool> exportPdf(
    Future<void> Function(Uint8List bytes, String fileName) share,
  ) => submit(() async {
    try {
      final data = pdfData;
      await share(await buildReportPdf(data), data.fileName);
      return null;
    } catch (_) {
      return 'PDF belum bisa dibuat. Coba lagi.';
    }
  });

  Future<bool> setAlerts(bool value) =>
      submit(() => _store.settings(alerts: value));
}
