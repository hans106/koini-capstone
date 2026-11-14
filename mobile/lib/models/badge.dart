class KoiniBadge {
  const KoiniBadge(this.name, this.description, this.progress, this.target);
  final String name;
  final String description;
  final int progress;
  final int target;

  bool get earned => progress >= target;
}
