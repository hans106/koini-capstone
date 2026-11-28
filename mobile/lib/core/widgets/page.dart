import 'package:flutter/material.dart';

import '../theme/koini_theme.dart';
import 'controls.dart';
import 'text.dart';

class Sky extends StatelessWidget {
  const Sky({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: KColors.sky,
      image: DecorationImage(
        image: AssetImage('assets/images/sky.png'),
        fit: BoxFit.fill,
      ),
    ),
    child: child,
  );
}

class KPage extends StatelessWidget {
  const KPage({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.back = true,
    this.footer,
    required this.children,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool back;
  final Widget? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Sky(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                if (title != null || leading != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                    child: Row(
                      children: [
                        ?leading,
                        if (leading == null && back) const KBack(),
                        if (back || leading != null) const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null) heading(title!, size: 23),
                              if (subtitle != null) caption(subtitle!),
                            ],
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 8),
                          trailing!,
                        ],
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      title == null ? 20 : 12,
                      24,
                      20,
                    ),
                    children: children,
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                    child: SizedBox(width: double.infinity, child: footer),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class KBack extends StatelessWidget {
  const KBack({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 44,
    child: KCard(
      padding: EdgeInsets.zero,
      bright: true,
      radius: 16,
      onTap: onTap ?? () => Navigator.maybePop(context),
      child: const Tooltip(
        message: 'Kembali',
        child: Icon(Icons.chevron_left_rounded, size: 30),
      ),
    ),
  );
}
