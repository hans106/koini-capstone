import 'package:flutter/material.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/models/koini_data.dart';

class DreamReport extends StatelessWidget {
  const DreamReport({
    super.key,
    required this.dream,
    required this.saved,
    required this.progress,
  });
  final int saved;
  final double progress;
  final Dream dream;

  @override
  Widget build(BuildContext context) => KCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        caption('Impian ${dream.name}'),
        Row(
          children: [
            Expanded(
              child: heading(
                '${rupiah(saved)} dari ${rupiah(dream.target)}',
                size: 16,
              ),
            ),
            heading(
              '${(progress * 100).round()}%',
              size: 25,
              color: KColors.gold,
            ),
          ],
        ),
        const Gap(6),
        GoalProgress(progress),
        if (dream.deadline != null) ...[
          const Gap(6),
          caption('Target ${dateLabel(dream.deadline!)}'),
        ],
      ],
    ),
  );
}
