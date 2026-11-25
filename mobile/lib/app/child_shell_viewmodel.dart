import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/services/koini_store.dart';

class ChildShellViewModel extends StoreViewModel {
  ChildShellViewModel(this._store) : super(_store);

  final KoiniStore _store;

  String get name => _store.name;
  int get streak => _store.streak;
  int get stars => _store.stars;
  int get dreamCount => _store.dreams.length;
  int get completedMissions => _store.scores.length;
  int get missionCount => _store.catalogMissions.length;
  bool get hasPlus => _store.hasPlus;
}
