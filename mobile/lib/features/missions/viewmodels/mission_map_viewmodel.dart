import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/mission.dart';
import 'package:koini/services/koini_store.dart';

class MissionMapViewModel extends StoreViewModel {
  MissionMapViewModel(this._store) : super(_store);
  final KoiniStore _store;

  List<Mission> get catalog => _store.catalogMissions;
  int get completed => _store.scores.length;
  int get _nextIndex =>
      catalog.indexWhere((mission) => !_store.scores.containsKey(mission.id));
  Mission get next {
    final index = _nextIndex;
    return index < 0 ? catalog.last : catalog[index];
  }

  Iterable<({Mission mission, bool locked, bool current})> get stops sync* {
    final nextIndex = _nextIndex;
    for (final (index, mission) in catalog.indexed) {
      yield (
        mission: mission,
        locked: nextIndex >= 0 && index > nextIndex,
        current: index == nextIndex,
      );
    }
  }
}
