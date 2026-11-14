import 'package:flutter/material.dart';

import '../theme/koini_theme.dart';
import 'text.dart';

class KCard extends StatelessWidget {
  const KCard({
    super.key,
    required this.child,
    this.onTap,
    this.border,
    this.bright = false,
    this.radius = 23,
    this.padding = const EdgeInsets.all(15),
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? border;
  final bool bright;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: border ?? KColors.line, width: 1.4),
    );
    return Material(
      shape: shape,
      color: bright ? KColors.bright : KColors.panel,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class KButton extends StatelessWidget {
  const KButton(
    this.label, {
    super.key,
    this.onTap,
    this.secondary = false,
    this.small = false,
    this.white = false,
  });
  final String label;
  final VoidCallback? onTap;
  final bool secondary;
  final bool small;
  final bool white;

  @override
  Widget build(BuildContext context) {
    final tint = white
        ? Colors.white
        : secondary
        ? KColors.bright
        : KColors.gold;
    final fg = white
        ? KColors.field
        : secondary
        ? Colors.white
        : KColors.ink;
    final radius = BorderRadius.circular(small ? 26 : 22);
    return Padding(
      padding: EdgeInsets.only(bottom: small ? 3 : 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: secondary
                  ? KColors.field
                  : white
                  ? KColors.soft
                  : KColors.shade,
              offset: Offset(0, small ? 3 : 5),
            ),
          ],
        ),
        child: Material(
          color: onTap == null ? KColors.panel : tint,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: Semantics(
            button: true,
            enabled: onTap != null,
            container: true,
            child: InkWell(
              onTap: onTap,
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(minHeight: small ? 36 : 56),
                padding: EdgeInsets.symmetric(
                  horizontal: small ? 14 : 16,
                  vertical: small ? 6 : 10,
                ),
                child: heading(
                  label,
                  size: small ? 15 : 20,
                  color: onTap == null ? KColors.soft : fg,
                  align: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(
    this.label, {
    super.key,
    this.onTap,
    this.selected = false,
    this.color,
    this.icon,
  });
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? KColors.ink : color ?? KColors.text;
    return Material(
      color: selected ? KColors.gold : KColors.bright,
      shape: StadiumBorder(
        side: BorderSide(color: color ?? KColors.line, width: 1.3),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 16),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KRow extends StatelessWidget {
  const KRow(
    this.title,
    this.subtitle, {
    super.key,
    this.onTap,
    this.icon,
    this.trailing,
    this.color,
    this.bright = false,
  });
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? icon;
  final Widget? trailing;
  final Color? color;
  final bool bright;

  @override
  Widget build(BuildContext context) => KCard(
    onTap: onTap,
    bright: bright,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 10)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(title, size: 17, color: color ?? Colors.white),
              if (subtitle.isNotEmpty) caption(subtitle),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ] else if (onTap != null)
          const Icon(Icons.chevron_right_rounded, color: KColors.gold),
      ],
    ),
  );
}
