class Mission {
  const Mission(this.id, this.name, this.questions);
  final String id;
  final String name;
  final List<Question> questions;
}

class Question {
  const Question(this.story, this.options, this.correct, this.explanation);
  final String story;
  final List<String> options;
  final int correct;
  final String explanation;
}
