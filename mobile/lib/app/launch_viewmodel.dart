import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/services/koini_store.dart';

enum LaunchStatus { loading, failed, welcome, childArea }

class LaunchViewModel extends ViewModel {
  LaunchViewModel(this._store);
  final KoiniStore _store;
  LaunchStatus _status = LaunchStatus.loading;
  LaunchStatus get status => _status;

  Future<void> load() async {
    _status = LaunchStatus.loading;
    changed();
    try {
      await Future.wait([
        _store.load(),
        Future<void>.delayed(const Duration(milliseconds: 850)),
      ]);
      _status = _store.hasProfile
          ? LaunchStatus.childArea
          : LaunchStatus.welcome;
    } catch (_) {
      _status = LaunchStatus.failed;
    }
    changed();
  }
}
