class Mission {
  const Mission(
    this.id,
    this.name,
    this.questions, {
    this.dbId,
    this.topic = '',
    this.level = 1,
  });

  final String id;
  final String name;
  final List<Question> questions;
  final int? dbId;
  final String topic;
  final int level;
}

class Question {
  const Question(
    this.story,
    this.options,
    this.correct,
    this.explanation, {
    this.wrongExplanation,
    this.source = '',
  });

  final String story;
  final List<String> options;
  final int correct;
  final String explanation;
  final String? wrongExplanation;
  final String source;
}
