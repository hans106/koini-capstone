import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class DatedGoalView extends StatefulWidget {
  const DatedGoalView({super.key, required this.store, required this.dream});
  final KoiniStore store;
  final Dream dream;

  @override
  State<DatedGoalView> createState() => _DatedGoalViewState();
}

class _DatedGoalViewState extends State<DatedGoalView> {
  late DateTime deadline =
      widget.dream.deadline?.isAfter(widget.store.now) == true
      ? widget.dream.deadline!
      : widget.store.now.add(const Duration(days: 84));
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final today = dayStart(widget.store.now);
    final difference = dayStart(deadline).difference(today).inDays;
    final weeks = ((difference + 6) ~/ 7).clamp(1, 999);
    final remaining = widget.store.remaining(widget.dream);
    final contribution = (remaining + weeks - 1) ~/ weeks;
    return KPage(
      title: 'Target bertanggal',
      footer: KButton(
        'Simpan target',
        onTap: busy || remaining == 0
            ? null
            : () async {
                setState(() => busy = true);
                final error = await widget.store.setDreamPlan(
                  widget.dream,
                  contribution,
                  deadline: deadline,
                );
                if (!context.mounted) return;
                if (error != null) {
                  setState(() => busy = false);
                  note(context, error);
                } else {
                  note(context, 'Target bertanggal tersimpan.');
                  Navigator.pop(context);
                }
              },
      ),
      children: [
        heading(
          'Kapan ${widget.dream.name} tercapai?',
          size: 20,
          color: KColors.gold,
        ),
        caption(
          'Pilih tanggal target. Koini menghitung tabungan per minggunya.',
        ),
        const Gap(),
        for (final days in [182, 112, 84]) ...[
          KCard(
            border:
                dayStart(deadline) == dayStart(today.add(Duration(days: days)))
                ? KColors.gold
                : null,
            onTap: () =>
                setState(() => deadline = today.add(Duration(days: days))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading(dateLabel(today.add(Duration(days: days))), size: 17),
                caption(
                  '${rupiah((remaining + days ~/ 7 - 1) ~/ (days ~/ 7))} per minggu · ${days ~/ 7} minggu',
                ),
              ],
            ),
          ),
          const Gap(7),
        ],
        KRow(
          'Pilih tanggal lain',
          dateLabel(deadline),
          onTap: () async {
            final choice = await showDatePicker(
              context: context,
              useRootNavigator: false,
              initialDate: deadline,
              firstDate: today.add(const Duration(days: 1)),
              lastDate: today.add(const Duration(days: 1825)),
            );
            if (choice != null && mounted) setState(() => deadline = choice);
          },
        ),
        const Gap(),
        KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(widget.dream.name, size: 18),
              caption('Kurang ${rupiah(remaining)}'),
              caption(
                '${rupiah(contribution)} per minggu selama $weeks minggu',
                color: KColors.mint,
              ),
            ],
          ),
        ),
        const Gap(),
        const KCallout(
          'Janji Ayah/Bunda',
          'Bicarakan rencana ini bersama agar kamu bisa menjaganya.',
        ),
      ],
    );
  }
}

@Preview(name: 'Target bertanggal', group: 'Plus', size: koiniPreviewSize)
Widget datedGoalPreview() => KoiniPreviewHost(
  page: (context, store) =>
      DatedGoalView(store: store, dream: store.activeDream!),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.dreams),
);
