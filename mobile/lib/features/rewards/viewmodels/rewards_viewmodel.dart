import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/features/rewards/viewmodels/badge_progress.dart';
import 'package:koini/models/badge.dart';
import 'package:koini/services/koini_store.dart';

class RewardsViewModel extends StoreViewModel {
  RewardsViewModel(this._store) : super(_store);
  final KoiniStore _store;

  String get name => _store.name;
  int get age => _store.age;
  int get streak => _store.streak;
  int get stars => _store.stars;
  Iterable<KoiniBadge> get earned =>
      badges(_store).where((item) => item.earned);
  Iterable<KoiniBadge> get locked =>
      badges(_store).where((item) => !item.earned);
}
