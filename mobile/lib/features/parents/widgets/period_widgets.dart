import 'package:flutter/material.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/models/koini_data.dart';

typedef ChartBucket = ({String label, Map<Jar, int> amounts});
typedef DayGroup = ({DateTime day, List<MoneyEntry> items});

/// Grafik batang sederhana: tiga batang (Tabung, Jajan, Berbagi) per hari
/// atau per minggu.
class PeriodChart extends StatelessWidget {
  const PeriodChart({super.key, required this.title, required this.buckets});

  final String title;
  final List<ChartBucket> buckets;

  static const _barArea = 84.0;

  @override
  Widget build(BuildContext context) {
    final highest = buckets
        .expand((bucket) => bucket.amounts.values)
        .fold<int>(0, (a, b) => a > b ? a : b);
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading(title, size: 16),
          const Gap(6),
          Wrap(
            spacing: 12,
            children: [
              for (final jar in Jar.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: KColors.jar(jar),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    caption(jar.label),
                  ],
                ),
            ],
          ),
          const Gap(10),
          SizedBox(
            height: _barArea + 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bucket in buckets)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final jar in Jar.values)
                              _Bar(
                                height: highest == 0
                                    ? 0
                                    : _barArea *
                                          (bucket.amounts[jar] ?? 0) /
                                          highest,
                                color: KColors.jar(jar),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        caption(bucket.label, align: TextAlign.center),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (highest == 0) ...[
            const Gap(4),
            caption('Belum ada catatan di periode ini.'),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    height: height > 0 && height < 3 ? 3 : height,
    margin: const EdgeInsets.symmetric(horizontal: 1),
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
    ),
  );
}

/// Riwayat dikelompokkan per hari, terbaru di atas.
class DayHistory extends StatelessWidget {
  const DayHistory({super.key, required this.groups});

  final List<DayGroup> groups;

  String _signed(MoneyEntry entry) {
    if (entry.expense > 0) return '-${rupiah(entry.expense)}';
    if (entry.income > 0) return '+${rupiah(entry.income)}';
    return rupiah(entry.amount);
  }

  Color _color(MoneyEntry entry) {
    if (entry.expense > 0) return KColors.peach;
    if (entry.income > 0) return KColors.mint;
    return KColors.soft;
  }

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const KRow('Belum ada aktivitas', '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups) ...[
          heading(dateLabel(group.day), size: 15),
          const Gap(4),
          KCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: [
                for (final entry in group.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.note.isEmpty
                                    ? entry.kind.label
                                    : entry.note,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              caption(entry.kind.label),
                            ],
                          ),
                        ),
                        heading(_signed(entry), size: 15, color: _color(entry)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Gap(8),
        ],
      ],
    );
  }
}
