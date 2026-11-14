import 'package:flutter/material.dart';

import '../theme/koini_theme.dart';
import 'controls.dart';
import 'illustration.dart';
import 'text.dart';

void note(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class Stat extends StatelessWidget {
  const Stat(
    this.label,
    this.value, {
    super.key,
    this.color = KColors.gold,
    this.border,
  });
  final String label;
  final String value;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) => KCard(
    border: border,
    radius: 18,
    padding: const EdgeInsets.all(11),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        caption(label),
        const Gap(3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: heading(value, size: 22, color: color),
        ),
      ],
    ),
  );
}

class KCallout extends StatelessWidget {
  const KCallout(
    this.title,
    this.message, {
    super.key,
    this.color = KColors.gold,
    this.action,
  });
  final String title;
  final String message;
  final Color color;
  final Widget? action;
  @override
  Widget build(BuildContext context) => KCard(
    child: Row(
      children: [
        const Mascot(coin: false, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(title, size: 17, color: color),
              if (message.isNotEmpty) caption(message),
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: 8), action!],
      ],
    ),
  );
}

Future<void> kSheet(
  BuildContext context,
  String title,
  String message, {
  String primary = 'Oke',
  String? secondary,
  VoidCallback? action,
  bool error = false,
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (sheet) => Padding(
    padding: EdgeInsets.fromLTRB(
      14,
      14,
      14,
      14 + MediaQuery.viewPaddingOf(sheet).bottom,
    ),
    child: KCard(
      border: error ? KColors.error : KColors.gold,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Mascot(coin: false, size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: heading(
                    title,
                    size: 21,
                    color: error ? KColors.error : KColors.gold,
                  ),
                ),
              ],
            ),
            const Gap(14),
            Text(message),
            const Gap(25),
            KButton(
              primary,
              onTap: () {
                Navigator.pop(sheet);
                action?.call();
              },
            ),
            if (secondary != null) ...[
              const Gap(8),
              KButton(
                secondary,
                secondary: true,
                onTap: () => Navigator.pop(sheet),
              ),
            ],
          ],
        ),
      ),
    ),
  ),
);
