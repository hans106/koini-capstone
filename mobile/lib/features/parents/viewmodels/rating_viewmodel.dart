import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/services/koini_store.dart';

class RatingViewModel extends ViewModel {
  RatingViewModel(this._store) : _rating = _store.rating;
  final KoiniStore _store;
  int _rating;

  int get rating => _rating;
  void select(int value) {
    _rating = value;
    changed();
  }

  Future<bool> save() => submit(() => _store.settings(rating: _rating));
}
