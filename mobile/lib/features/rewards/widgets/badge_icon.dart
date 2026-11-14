import 'package:flutter/material.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/models/badge.dart';

class BadgeIcon extends StatelessWidget {
  const BadgeIcon(this.earned, {super.key});
  final bool earned;
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 18,
    backgroundColor: earned ? KColors.gold : KColors.bright,
    child: Icon(
      earned ? Icons.star : Icons.lock_outline_rounded,
      size: 22,
      color: earned ? KColors.ink : KColors.soft,
    ),
  );
}

void showBadge(BuildContext context, KoiniBadge badge) => kSheet(
  context,
  badge.name,
  '${badge.description}. ${badge.earned ? 'Lencana sudah diperoleh!' : 'Progres ${badge.progress} dari ${badge.target}.'}',
);
