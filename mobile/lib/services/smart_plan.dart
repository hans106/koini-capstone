import 'dart:math';

class SmartPlan {
  const SmartPlan({
    required this.target,
    required this.saved,
    required this.weekly,
  });

  final int target;
  final int saved;
  final int weekly;

  int get remaining => max(0, target - saved);
  int get weeks => (remaining + weekly - 1) ~/ weekly;
  int balanceAt(int week) => min(target, saved + week * weekly);
}
