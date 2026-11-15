import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/features/missions/mission_content.dart';
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
  String get missionFraction => '${_store.scores.length}/${missions.length}';
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

  Iterable<({String name, String result})> get completedMissions sync* {
    final scores = _store.scores;
    for (final mission in missions) {
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

  Future<bool> setAlerts(bool value) =>
      submit(() => _store.settings(alerts: value));
}
