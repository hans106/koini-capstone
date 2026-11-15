import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/dreams/viewmodels/dreams_viewmodel.dart';
import 'package:koini/features/dreams/widgets/dream_image.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class DreamDetailView extends StatefulWidget {
  const DreamDetailView({
    super.key,
    required this.store,
    required this.id,
    this.parentAccess,
  });
  final KoiniStore store;
  final String id;
  final VoidCallback? parentAccess;

  @override
  State<DreamDetailView> createState() => _DreamDetailViewState();
}

class _DreamDetailViewState extends State<DreamDetailView> {
  KoiniStore get store => widget.store;
  late final model = DreamsViewModel(store);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) {
      final dream = model.find(widget.id);
      final progress = model.progress(dream);
      final remaining = model.remaining(dream);
      final next = [
        25,
        50,
        100,
      ].where((value) => progress * 100 < value).firstOrNull;
      return KPage(
        title: dream.name,
        footer: KButton(
          remaining == 0 ? 'Daftar impian' : 'Tambah tabungan',
          onTap: remaining == 0
              ? () => Navigator.pop(context)
              : () => openPage(
                  context,
                  AddTransactionView(
                    store: store,
                    kind: EntryKind.save,
                    dream: dream,
                  ),
                ),
        ),
        children: [
          const Gap(12),
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: KColors.gold.withValues(alpha: .14),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: dreamImage(dream, size: 112),
            ),
          ),
          const Gap(8),
          caption('Sudah ditabung', align: TextAlign.center),
          heading(
            rupiah(model.savedFor(dream)),
            size: 37,
            color: KColors.gold,
            align: TextAlign.center,
          ),
          Constellation(progress),
          caption(
            '${(progress * 100).round()}% · Target ${rupiah(dream.target)} · Kurang ${rupiah(remaining)}',
            align: TextAlign.center,
          ),
          const Gap(15),
          heading('Jejak langkahmu', size: 18),
          const Gap(6),
          Row(
            children: [
              for (final milestone in [25, 50, 100]) ...[
                if (milestone != 25) const SizedBox(width: 6),
                Expanded(
                  child: KCard(
                    border: milestone == next
                        ? KColors.gold
                        : progress * 100 >= milestone
                        ? KColors.mint
                        : null,
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 3,
                    ),
                    child: Column(
                      children: [
                        heading(
                          '$milestone%',
                          size: 19,
                          color: progress * 100 >= milestone
                              ? KColors.mint
                              : milestone == next
                              ? KColors.gold
                              : Colors.white,
                        ),
                        caption(
                          progress * 100 >= milestone
                              ? 'Terlewati'
                              : milestone == next
                              ? 'Berikutnya'
                              : 'Terwujud',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Gap(),
          KCallout(
            remaining == 0 ? 'Impian terwujud!' : 'Makin dekat!',
            remaining == 0
                ? 'Ajak Ayah/Bunda merayakan.'
                : 'Terus menabung, ya!',
            action: Pill(
              'Rencana',
              color: KColors.gold,
              icon: Icons.star,
              onTap: () => openSmartPlan(
                context,
                store,
                dream,
                parentAccess: widget.parentAccess,
              ),
            ),
          ),
          const Gap(10),
          if (remaining > 0)
            KRow(
              'Target bertanggal',
              dream.deadline != null
                  ? dateLabel(dream.deadline!)
                  : 'Pilih tanggal untuk impianmu · Tahunan',
              onTap: () => openDatedGoal(
                context,
                store,
                dream,
                parentAccess: widget.parentAccess,
              ),
            ),
          const Gap(9),
          if (remaining > 0)
            KButton(
              'Simulasi',
              secondary: true,
              onTap: () {
                final plan = model.simulation(dream);
                kSheet(
                  context,
                  'Simulasi impian',
                  'Dengan ${rupiah(plan.weekly)} per minggu, '
                      '${dream.name} bisa tercapai dalam ${plan.weeks} minggu.',
                );
              },
            ),
        ],
      );
    },
  );
}

@Preview(name: 'Detail sepeda - 40%', group: 'Impian', size: koiniPreviewSize)
Widget dreamDetailPreview() => KoiniPreviewHost(
  page: (context, store) => DreamDetailView(
    store: store,
    id: store.activeDream!.id,
    parentAccess: () => openParentArea(context, store),
  ),
  scenario: PreviewScenario.dream,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.dreams),
);
