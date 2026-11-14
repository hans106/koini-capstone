import 'package:flutter/widgets.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

class SmartPlanController extends ChangeNotifier {
  SmartPlanController(this.store, this.dream);

  final KoiniStore store;
  final Dream? dream;
  late final target = TextEditingController(
    text: dream?.target.toString() ?? '',
  );
  late final saved = TextEditingController(
    text: dream == null ? '0' : store.savedFor(dream!).toString(),
  );
  late final weekly = TextEditingController(
    text: (dream?.weekly ?? 20000).toString(),
  );
  bool working = false;
  bool _disposed = false;

  SmartPlan? get estimate {
    final amount = int.tryParse(target.text) ?? 0;
    final current = int.tryParse(saved.text) ?? -1;
    final perWeek = int.tryParse(weekly.text) ?? 0;
    if (amount <= 0 || current < 0 || perWeek <= 0) return null;
    return SmartPlan(target: amount, saved: current, weekly: perWeek);
  }

  void chooseWeekly(int amount) {
    weekly.text = '$amount';
    notifyListeners();
  }

  void refresh() => notifyListeners();

  Future<void> showCalculation() async {
    working = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 550));
    working = false;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    target.dispose();
    saved.dispose();
    weekly.dispose();
    super.dispose();
  }
}
