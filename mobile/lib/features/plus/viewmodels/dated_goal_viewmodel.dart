import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

class DatedGoalViewModel extends StoreViewModel {
  DatedGoalViewModel(this._store, this.dream) : super(_store) {
    final savedDate = dream.deadline;
    _deadline = savedDate != null && savedDate.isAfter(_store.now)
        ? savedDate
        : _store.now.add(const Duration(days: 84));
  }
  final KoiniStore _store;
  final Dream dream;
  late DateTime _deadline;

  DateTime get today => dayStart(_store.now);
  DateTime get deadline => _deadline;
  int get remaining => _store.remaining(dream);
  int get weeks =>
      ((dayStart(deadline).difference(today).inDays + 6) ~/ 7).clamp(1, 999);
  int get contribution => contributionFor(weeks);
  int contributionFor(int weeks) =>
      SmartPlan.weeklyContribution(remaining, weeks);

  void chooseDate(DateTime date) {
    _deadline = date;
    changed();
  }

  Future<bool> save() => submit(
    () => _store.setDreamPlan(dream, contribution, deadline: deadline),
  );
}
