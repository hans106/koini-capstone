import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

class SmartPlanViewModel extends ViewModel {
  SmartPlanViewModel(KoiniStore store, Dream? dream)
    : _target = dream?.target ?? 0,
      _saved = dream == null ? 0 : store.savedFor(dream),
      _weekly = dream?.weekly ?? 20000;

  int _target;
  int _saved;
  int _weekly;

  String get targetText => _target > 0 ? '$_target' : '';
  String get savedText => '$_saved';
  int get weekly => _weekly;

  void changeTarget(String value) => _target = int.tryParse(value) ?? 0;
  void changeSaved(String value) => _saved = int.tryParse(value) ?? -1;
  void changeWeekly(String value) {
    _weekly = int.tryParse(value) ?? 0;
    changed();
  }

  Future<SmartPlan?> calculate() async {
    if (busy) return null;
    if (_target <= 0 || _saved < 0 || _weekly <= 0) {
      showError('Isi target, tabungan saat ini, dan nominal per minggu.');
      return null;
    }
    final plan = SmartPlan(target: _target, saved: _saved, weekly: _weekly);
    await submit(() async {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      return null;
    });
    return plan;
  }
}
