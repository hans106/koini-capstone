import 'package:koini/core/utils/keypad_value.dart';
import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

class PiggyCheckViewModel extends StoreViewModel {
  PiggyCheckViewModel(this._store) : super(_store);

  final KoiniStore _store;
  String _digits = '';
  PiggyBankCheck? _lastSaved;

  int get physicalAmount => int.tryParse(_digits) ?? 0;
  bool get hasInput => _digits.isNotEmpty;
  int get recordedTotal => _store.total;
  int get tabungBalance => _store.balance(Jar.tabung);
  int get jajanBalance => _store.balance(Jar.jajan);
  int get berbagiBalance => _store.balance(Jar.berbagi);
  int get difference => physicalAmount - recordedTotal;
  List<PiggyBankCheck> get history => _store.piggyChecks;
  PiggyBankCheck? get lastSaved => _lastSaved;

  void enterDigit(String key) {
    if (busy) return;
    _digits = keypadValue(_digits, key, 9);
    _lastSaved = null;
    changed();
  }

  Future<bool> save() async {
    if (busy) return false;
    final amount = physicalAmount;
    final ok = await submit(() => _store.recordPiggyBankCheck(amount));
    if (ok) {
      _lastSaved = _store.piggyChecks.firstOrNull;
      _digits = '';
      changed();
    }
    return ok;
  }
}
