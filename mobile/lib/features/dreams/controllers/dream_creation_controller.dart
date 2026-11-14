import 'package:flutter/widgets.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

class DreamCreationController extends ChangeNotifier {
  DreamCreationController(this.store);

  final KoiniStore store;
  final name = TextEditingController();
  final target = TextEditingController();
  int image = 0;
  int weekly = 10000;
  bool busy = false;
  bool _disposed = false;

  SmartPlan? get plan {
    final amount = int.tryParse(target.text) ?? 0;
    return amount > 0
        ? SmartPlan(target: amount, saved: 0, weekly: weekly)
        : null;
  }

  void refreshEstimate() => notifyListeners();
  void selectImage(int value) {
    image = value;
    notifyListeners();
  }

  void selectWeekly(int value) {
    weekly = value;
    notifyListeners();
  }

  Future<String?> save() async {
    if (busy) return 'Koini sedang menyimpan. Coba lagi sebentar.';
    busy = true;
    notifyListeners();
    final error = await store.addDream(
      name.text,
      image,
      plan?.target ?? 0,
      weekly,
    );
    if (error != null) {
      busy = false;
      if (!_disposed) notifyListeners();
    }
    return error;
  }

  @override
  void dispose() {
    _disposed = true;
    name.dispose();
    target.dispose();
    super.dispose();
  }
}
