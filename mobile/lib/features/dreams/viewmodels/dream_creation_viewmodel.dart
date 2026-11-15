import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/services/koini_store.dart';
import 'package:koini/services/smart_plan.dart';

class DreamCreationViewModel extends ViewModel {
  DreamCreationViewModel(this._store);

  final KoiniStore _store;
  String _name = '';
  int _target = 0;
  int _image = 0;
  int _weekly = 10000;

  String get dreamName => _name.trim();
  int get image => _image;
  int get weekly => _weekly;
  SmartPlan? get plan => _target > 0
      ? SmartPlan(target: _target, saved: 0, weekly: _weekly)
      : null;

  void changeName(String value) => _name = value;
  void changeTarget(String value) {
    _target = int.tryParse(value) ?? 0;
    changed();
  }

  void selectImage(int value) {
    _image = value;
    changed();
  }

  void selectWeekly(int value) {
    _weekly = value;
    changed();
  }

  Future<bool> save() =>
      submit(() => _store.addDream(dreamName, _image, _target, _weekly));
}
