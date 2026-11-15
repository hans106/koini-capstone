import 'package:flutter/material.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/models/transaction_totals.dart';

class EntryRow extends StatelessWidget {
  const EntryRow(this.entry, {super.key});
  final MoneyEntry entry;

  @override
  Widget build(BuildContext context) {
    final prefix = entry.expense > 0
        ? '−'
        : entry.income > 0
        ? '+'
        : '';
    return KRow(
      entry.kind.label,
      [
        if (entry.note.isNotEmpty) entry.note,
        if (entry.category != null) entry.category!,
      ].join(' · '),
      icon: Icon(Icons.circle, color: entryColor(entry.kind), size: 14),
      trailing: heading('$prefix${rupiah(entry.amount)}', size: 15),
    );
  }
}

Color entryColor(EntryKind kind) => switch (kind) {
  EntryKind.save => KColors.mint,
  EntryKind.spend => KColors.peach,
  EntryKind.give => KColors.lavender,
  _ => KColors.gold,
};

class Totals extends StatelessWidget {
  const Totals(this.totals, {super.key});
  final TransactionTotals totals;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stat('Masuk', rupiah(totals.income), border: KColors.gold),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Stat(
            'Keluar',
            rupiah(totals.expense),
            color: KColors.peach,
            border: KColors.peach,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Stat(
            'Ditabung',
            rupiah(totals.saved),
            color: KColors.mint,
            border: KColors.mint,
          ),
        ),
      ],
    );
  }
}
