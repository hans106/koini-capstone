import 'package:flutter/widgets.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class AllowanceSettingsController extends ChangeNotifier {
  AllowanceSettingsController(this.store);

  final KoiniStore store;
  late final amount = TextEditingController(text: store.allowance.toString());
  late final limit = TextEditingController(text: store.dailyLimit.toString());
  late int total = store.allowance;
  late Map<Jar, int> split = Map.of(store.split);
  bool busy = false;
  bool _disposed = false;

  void changeAmount(String value) {
    total = int.tryParse(value) ?? 0;
    split = KoiniStore.defaultSplit(total);
    notifyListeners();
  }

  void changeSplit(Map<Jar, int> value) => split = value;

  Future<String?> save() async {
    if (busy) return 'Koini sedang menyimpan. Coba lagi sebentar.';
    busy = true;
    notifyListeners();
    final error = await store.setAllowance(
      total,
      int.tryParse(limit.text) ?? 0,
      split,
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
    amount.dispose();
    limit.dispose();
    super.dispose();
  }
}
