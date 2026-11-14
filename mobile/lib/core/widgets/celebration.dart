import 'package:flutter/material.dart';

import '../theme/koini_theme.dart';
import 'controls.dart';
import 'illustration.dart';
import 'page.dart';
import 'text.dart';

class Celebration extends StatelessWidget {
  const Celebration({
    super.key,
    required this.title,
    required this.message,
    required this.button,
    this.header,
    this.details = const [],
  });
  final String title;
  final String message;
  final String button;
  final String? header;
  final List<Widget> details;

  @override
  Widget build(BuildContext context) => KPage(
    title: header,
    footer: KButton(button, onTap: () => Navigator.pop(context)),
    children: [
      const Gap(20),
      Center(
        child: SizedBox(
          width: 285,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: .7, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: const Mascot(glow: true, size: 136),
              ),
              const Positioned(
                left: 21,
                top: 14,
                child: Icon(Icons.star, color: KColors.gold, size: 31),
              ),
              const Positioned(
                right: 13,
                top: 3,
                child: Icon(Icons.star, color: KColors.gold, size: 44),
              ),
              const Positioned(
                left: 9,
                bottom: 23,
                child: Icon(Icons.star, color: KColors.gold, size: 20),
              ),
              const Positioned(
                right: 15,
                bottom: 18,
                child: Icon(Icons.star, color: KColors.gold, size: 23),
              ),
            ],
          ),
        ),
      ),
      heading(title, size: 33, color: KColors.gold, align: TextAlign.center),
      const Gap(8),
      Text(message, textAlign: TextAlign.center),
      if (details.isNotEmpty) const Gap(18),
      ...details,
    ],
  );
}
