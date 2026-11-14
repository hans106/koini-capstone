import 'package:flutter/material.dart';

import '../theme/koini_theme.dart';

class Illustration extends StatelessWidget {
  const Illustration(this.name, {super.key, this.size = 48});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) =>
      Image.asset(art(name), width: size, height: size, fit: BoxFit.contain);
}

class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.size = 146,
    this.glow = false,
    this.coin = true,
  });
  final double size;
  final bool glow;
  final bool coin;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: glow
          ? [
              BoxShadow(
                color: KColors.gold.withValues(alpha: .20),
                blurRadius: 49,
                spreadRadius: 15,
              ),
            ]
          : const [],
    ),
    child: Image.asset(
      'assets/images/${coin ? 'mascot' : 'bird'}.png',
      fit: BoxFit.contain,
    ),
  );
}
