import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/plus/viewmodels/dated_goal_viewmodel.dart';
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
  late final model = DatedGoalViewModel(widget.store, widget.dream);

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: model, builder: buildPage);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Widget buildPage(BuildContext context, Widget? child) {
    final today = model.today;
    final deadline = model.deadline;
    final weeks = model.weeks;
    final remaining = model.remaining;
    final contribution = model.contribution;
    return KPage(
      title: 'Target bertanggal',
      footer: KButton(
        'Simpan target',
        onTap: model.busy || remaining == 0
            ? null
            : () async {
                if (model.busy) return;
                final saved = await model.save();
                if (!context.mounted) return;
                if (!saved) {
                  note(context, model.error!);
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
            onTap: () => model.chooseDate(today.add(Duration(days: days))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading(dateLabel(today.add(Duration(days: days))), size: 17),
                caption(
                  '${rupiah(model.contributionFor(days ~/ 7))} per minggu · ${days ~/ 7} minggu',
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
            if (choice != null && mounted) model.chooseDate(choice);
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
