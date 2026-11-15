import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/features/missions/mission_content.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/models/mission.dart';
import 'package:koini/services/koini_store.dart';

class HomeViewModel extends StoreViewModel {
  HomeViewModel(this._store) : super(_store);
  final KoiniStore _store;

  Dream? get activeDream => _store.activeDream;
  int get spentThisWeek => _store.amountFor(EntryKind.spend, _store.thisWeek);
  int get allowance => _store.allowance;
  int get jajanAllocation => _store.split[Jar.jajan]!;
  int get total => _store.total;
  bool get receivedThisWeek => _store.receivedThisWeek;
  int balance(Jar jar) => _store.balance(jar);
  int savedFor(Dream dream) => _store.savedFor(dream);
  int remaining(Dream dream) => _store.remaining(dream);
  double progress(Dream dream) => _store.progress(dream);
  Mission get nextMission => missions.firstWhere(
    (mission) => !_store.scores.containsKey(mission.id),
    orElse: () => missions.last,
  );

  Future<bool> receiveAllowance() => submit(_store.receiveAllowance);
}
