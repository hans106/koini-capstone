import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/services/koini_store.dart';

class ChangePinViewModel extends ViewModel {
  ChangePinViewModel(this._store);
  final KoiniStore _store;

  Future<bool> save(String current, String next, String confirm) async {
    if (busy) return false;
    if (current.length != 6 || next.length != 6 || next != confirm) {
      showError('Isi PIN lama dan ulangi PIN baru 6 angka.');
      return false;
    }
    return submit(() => _store.updatePin(current, next));
  }
}
