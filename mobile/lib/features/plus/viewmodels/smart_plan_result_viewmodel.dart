import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

class SmartPlanResultViewModel extends StoreViewModel {
  SmartPlanResultViewModel(this._store, this.dream, this.plan) : super(_store);
  final KoiniStore _store;
  final Dream? dream;
  final SmartPlan plan;

  bool get canSave {
    final goal = dream;
    return goal != null &&
        plan.target == goal.target &&
        plan.saved == _store.savedFor(goal) &&
        plan.weeks > 0;
  }

  Future<bool> save() async {
    final goal = dream;
    if (goal == null || !canSave) {
      showError('Buat perkiraan baru agar sesuai dengan progres impianmu.');
      return false;
    }
    return submit(() => _store.setDreamPlan(goal, plan.weekly));
  }
}
