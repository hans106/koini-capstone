import 'package:flutter/foundation.dart';
import 'package:koini/models/mission.dart';
import 'package:koini/services/koini_store.dart';

class MissionQuizController extends ChangeNotifier {
  MissionQuizController(this.store, this.mission);

  final KoiniStore store;
  final Mission mission;
  int index = 0;
  int correct = 0;
  int? selected;
  bool _missedFirstTry = false;
  bool saving = false;
  bool _disposed = false;

  Question get question => mission.questions[index];
  bool get correctAnswer => selected == question.correct;
  int get questionCount => mission.questions.length;

  void answer(int index) {
    if (selected != null) return;
    selected = index;
    if (!correctAnswer) _missedFirstTry = true;
    notifyListeners();
  }

  Future<({int score, int awarded, String? error})?> next() async {
    if (saving || selected == null) return null;
    if (!correctAnswer) {
      selected = null;
      notifyListeners();
      return null;
    }
    // A retry teaches the answer without awarding a first-attempt point.
    final score = correct + (_missedFirstTry ? 0 : 1);
    if (index + 1 < questionCount) {
      correct = score;
      index++;
      selected = null;
      _missedFirstTry = false;
      notifyListeners();
      return null;
    }

    saving = true;
    notifyListeners();
    final before = store.stars;
    final error = await store.completeMission(mission.id, score);
    if (error != null) {
      saving = false;
      if (!_disposed) notifyListeners();
    }
    return (score: score, awarded: store.stars - before, error: error);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
