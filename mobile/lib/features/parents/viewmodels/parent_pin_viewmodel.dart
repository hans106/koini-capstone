import 'package:koini/core/utils/keypad_value.dart';
import 'package:koini/core/viewmodels/view_model.dart';

class ParentPinViewModel extends ViewModel {
  ParentPinViewModel(this._verify);

  final Future<String?> Function(String) _verify;
  String _code = '';

  int get length => _code.length;

  void enterDigit(String key) {
    if (busy) return;
    _code = keypadValue(_code, key, 6);
    showError(null);
  }

  Future<bool> verify() async {
    if (busy) return false;
    if (length != 6) {
      showError('Masukkan 6 angka PIN.');
      return false;
    }
    final code = _code;
    return submit(() async {
      final problem = await _verify(code);
      _code = '';
      return problem;
    });
  }
}
