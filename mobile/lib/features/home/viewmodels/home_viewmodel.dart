import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/models/mission.dart';
import 'package:koini/services/koini_store.dart';

class HomeViewModel extends StoreViewModel {
  HomeViewModel(this._store) : super(_store);
  final KoiniStore _store;

  Dream? get activeDream => _store.activeDream;
  int get spentThisWeek =>
      _store.amountFor(EntryKind.spend, _store.currentPeriodEntries);
  int get allowance => _store.allowance;
  AllowancePeriod get allowancePeriod => _store.allowancePeriod;
  int get jajanAllocation => _store.split[Jar.jajan]!;
  int get total => _store.total;
  bool get receivedThisWeek => _store.receivedThisPeriod;
  bool get tutorialDone => _store.tutorialDone;
  int balance(Jar jar) => _store.balance(jar);
  int savedFor(Dream dream) => _store.savedFor(dream);
  int remaining(Dream dream) => _store.remaining(dream);
  double progress(Dream dream) => _store.progress(dream);
  Mission get nextMission => _store.catalogMissions.firstWhere(
    (mission) => !_store.scores.containsKey(mission.id),
    orElse: () => _store.catalogMissions.last,
  );

  Future<bool> receiveAllowance() => submit(_store.receiveAllowance);
  Future<int> sweepLeftoverJajan() => _store.sweepLeftoverJajan();
  Future<void> completeTutorial() => _store.completeTutorial();
}
