import 'package:flutter/material.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/models/koini_data.dart';

class JarSplitEditor extends StatefulWidget {
  const JarSplitEditor({
    super.key,
    required this.amount,
    required this.initial,
    required this.onChanged,
    this.period = AllowancePeriod.weekly,
  });
  final int amount;
  final Map<Jar, int> initial;
  final ValueChanged<Map<Jar, int>> onChanged;
  final AllowancePeriod period;

  @override
  State<JarSplitEditor> createState() => _JarSplitEditorState();
}

class _JarSplitEditorState extends State<JarSplitEditor> {
  late Map<Jar, int> values = Map.of(widget.initial);
  int get remainder =>
      widget.amount - values.values.fold(0, (sum, value) => sum + value);
  int get increment => widget.amount >= 100000
      ? 10000
      : widget.amount >= 10000
      ? 1000
      : 100;

  void change(Jar jar, int delta) {
    final current = values[jar]!;
    setState(
      () => values[jar] = (current + delta).clamp(0, current + remainder),
    );
    widget.onChanged(Map.of(values));
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      KCard(
        bright: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            caption('Uang saku ${widget.period.label.toLowerCase()}'),
            heading(rupiah(widget.amount), size: 30, color: KColors.gold),
            caption(
              'Bagi uang saku. Tiap ketukan hingga ${rupiah(increment)}.',
            ),
          ],
        ),
      ),
      for (final jar in Jar.values) ...[
        const Gap(9),
        KCard(
          child: Row(
            children: [
              Illustration(jarArt(jar), size: 31),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading(jar.label, size: 16, color: KColors.jar(jar)),
                    caption(jar.description),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: values[jar] == 0
                    ? null
                    : () => change(jar, -increment),
                tooltip: 'Kurangi ${jar.label}',
                icon: const Icon(Icons.remove, size: 16),
              ),
              SizedBox(
                width: 76,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: heading(rupiah(values[jar]!), size: 16),
                ),
              ),
              IconButton.filledTonal(
                onPressed: remainder == 0 ? null : () => change(jar, increment),
                tooltip: 'Tambah ${jar.label}',
                icon: const Icon(Icons.add, size: 16),
              ),
            ],
          ),
        ),
      ],
      const Gap(),
      KCard(
        border: KColors.gold,
        child: Row(
          children: [
            Expanded(child: heading('Sisa belum dibagi', size: 17)),
            heading(rupiah(remainder), color: KColors.gold),
          ],
        ),
      ),
    ],
  );
}
