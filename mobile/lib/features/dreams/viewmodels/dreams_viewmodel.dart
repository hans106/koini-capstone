import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

class DreamsViewModel extends StoreViewModel {
  DreamsViewModel(this._store) : super(_store);
  final KoiniStore _store;

  Iterable<Dream> get dreams => _store.dreams;
  Iterable<Dream> get activeDreams =>
      dreams.where((dream) => remaining(dream) > 0);
  Dream? get featured => _store.activeDream;
  Dream find(String id) => dreams.firstWhere((dream) => dream.id == id);
  int savedFor(Dream dream) => _store.savedFor(dream);
  int remaining(Dream dream) => _store.remaining(dream);
  double progress(Dream dream) => _store.progress(dream);
  SmartPlan simulation(Dream dream) => SmartPlan(
    target: dream.target,
    saved: savedFor(dream),
    weekly: dream.weekly,
  );
}
