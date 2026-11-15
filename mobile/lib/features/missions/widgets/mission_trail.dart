import 'package:flutter/material.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/models/mission.dart';
import 'package:koini/services/koini_store.dart';

class MissionStop extends StatelessWidget {
  const MissionStop({
    super.key,
    required this.mission,
    required this.store,
    required this.locked,
    required this.current,
    required this.reversed,
  });
  final Mission mission;
  final KoiniStore store;
  final bool locked;
  final bool current;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final star = SizedBox.square(
      dimension: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            locked ? Icons.star_outline : Icons.star,
            size: 54,
            color: locked ? KColors.line : KColors.gold,
          ),
          if (current) const Mascot(coin: false, size: 33),
        ],
      ),
    );
    final label = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: reversed
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        heading(
          mission.name,
          size: 17,
          color: current ? KColors.gold : Colors.white,
        ),
        const Gap(3),
        Pill(
          locked
              ? 'Terkunci'
              : current
              ? 'Main'
              : 'Selesai',
          color: locked
              ? null
              : current
              ? KColors.gold
              : KColors.mint,
          selected: current,
        ),
      ],
    );
    return InkWell(
      onTap: locked
          ? () => kSheet(
              context,
              'Misi masih terkunci',
              'Selesaikan misi sebelumnya untuk lanjut.',
            )
          : () => openPage(
              context,
              KRoute.quiz,
              pathParameters: {'id': mission.id},
            ),
      child: Row(
        children: [
          if (!reversed) star,
          const SizedBox(width: 6),
          Expanded(child: label),
          const SizedBox(width: 6),
          if (reversed) star,
        ],
      ),
    );
  }
}

class MissionTrail extends CustomPainter {
  const MissionTrail({required this.progress});
  final int progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 1; i < 4; i++) {
      final start = i.isOdd ? 26.0 : size.width - 26;
      final end = i.isOdd ? size.width - 26 : 26.0;
      final top = size.height * (i - .5) / 4;
      final bottom = size.height * (i + .5) / 4;
      final segment = Path()
        ..moveTo(start, top)
        ..cubicTo(
          start,
          (top + bottom) / 2,
          end,
          (top + bottom) / 2,
          end,
          bottom,
        );
      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = i <= progress ? KColors.gold : KColors.line,
      );
    }
  }

  @override
  bool shouldRepaint(MissionTrail oldDelegate) =>
      progress != oldDelegate.progress;
}
