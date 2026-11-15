import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/models/mission.dart';
import 'package:koini/services/koini_store.dart';

class MissionQuizViewModel extends ViewModel {
  MissionQuizViewModel(this._store, this.mission);

  final KoiniStore _store;
  final Mission mission;
  int _index = 0;
  int get index => _index;
  int _correct = 0;
  int? _selected;
  int? get selected => _selected;
  bool _missedFirstTry = false;
  int get stars => _store.stars;
  int get streak => _store.streak;

  Question get question => mission.questions[index];
  bool get correctAnswer => selected == question.correct;
  int get questionCount => mission.questions.length;

  void answer(int index) {
    if (selected != null) return;
    _selected = index;
    if (!correctAnswer) _missedFirstTry = true;
    changed();
  }

  Future<({int score, int awarded, String? error})?> next() async {
    if (busy || selected == null) return null;
    if (!correctAnswer) {
      _selected = null;
      changed();
      return null;
    }
    // A retry teaches the answer without awarding a first-attempt point.
    final score = _correct + (_missedFirstTry ? 0 : 1);
    if (index + 1 < questionCount) {
      _correct = score;
      _index++;
      _selected = null;
      _missedFirstTry = false;
      changed();
      return null;
    }

    final before = _store.stars;
    final saved = await submit(() => _store.completeMission(mission.id, score));
    return (
      score: score,
      awarded: saved ? _store.stars - before : 0,
      error: error,
    );
  }
}
