import 'package:flutter/material.dart';

import '../theme/koini_theme.dart';

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < 6; i++) ...[
        if (i > 0) const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: KColors.field,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: KColors.gold),
            ),
            child: i < count
                ? const Icon(Icons.circle, size: 11, color: KColors.gold)
                : null,
          ),
        ),
      ],
    ],
  );
}
