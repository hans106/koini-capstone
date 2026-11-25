import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class RewardChallengeViewModel extends StoreViewModel {
  RewardChallengeViewModel(this._store, {required this.parentMode})
    : super(_store);

  final KoiniStore _store;
  final bool parentMode;

  ChallengeKind _kind = ChallengeKind.examScore;
  String _title = '';
  String _requirement = '';
  int _reward = 10000;
  String? _dreamId;

  bool get hasPlus => _store.hasPlus;
  List<RewardChallenge> get challenges => _store.challenges;
  List<Dream> get dreams => _store.dreams;
  ChallengeKind get kind => _kind;
  int get reward => _reward;
  String? get selectedDreamId => _dreamId ?? _store.activeDream?.id;

  void setKind(ChallengeKind value) {
    _kind = value;
    changed();
  }

  void setTitle(String value) => _title = value;
  void setRequirement(String value) => _requirement = value;
  void setReward(String value) => _reward = int.tryParse(value) ?? 0;

  void setDream(String? id) {
    _dreamId = id;
    changed();
  }

  String? dreamName(String? id) {
    if (id == null) return null;
    return _store.dreams.where((d) => d.id == id).firstOrNull?.name;
  }

  Future<bool> create() {
    final dream = _store.dreams
        .where((d) => d.id == selectedDreamId)
        .firstOrNull;
    return submit(
      () => _store.addChallenge(
        title: _title,
        kind: _kind,
        requirement: _requirement,
        reward: _reward,
        dream: dream,
      ),
    );
  }

  Future<bool> markWaiting(String id) =>
      submit(() => _store.markChallengeWaiting(id));

  Future<bool> confirm(String id, {required bool succeeded}) =>
      submit(() => _store.resolveChallenge(id, succeeded: succeeded));
}
