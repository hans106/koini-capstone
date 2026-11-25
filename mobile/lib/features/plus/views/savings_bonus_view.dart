import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/plus/viewmodels/savings_bonus_viewmodel.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<SavingsBonusViewModel, SavingsBonusView>(
      (ref, view) =>
          SavingsBonusViewModel(view.store, parentMode: view.parentMode),
    );

class SavingsBonusView extends ConsumerStatefulWidget {
  const SavingsBonusView({
    super.key,
    required this.store,
    this.parentMode = false,
  });

  final KoiniStore store;
  final bool parentMode;

  @override
  ConsumerState<SavingsBonusView> createState() => _SavingsBonusViewState();
}

class _SavingsBonusViewState extends ConsumerState<SavingsBonusView> {
  final _minController = TextEditingController(text: '50000');
  final _bonusController = TextEditingController(text: '5000');

  late final _provider = _viewModelProvider(widget);
  SavingsBonusViewModel get model => ref.read(_provider);

  @override
  void dispose() {
    _minController.dispose();
    _bonusController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    FocusScope.of(context).unfocus();
    final ok = await model.create();
    if (!mounted) return;
    if (ok) {
      note(context, 'Janji Bonus Tabungan berhasil dibuat!');
    } else {
      note(
        context,
        model.error ?? 'Periksa nominal bonus dan syarat tabungan.',
      );
    }
  }

  Future<void> _resolve(SavingsBonus item, bool succeeded) async {
    final ok = await model.resolve(item.id, succeeded: succeeded);
    if (!mounted) return;
    if (ok) {
      note(
        context,
        succeeded
            ? 'Hore! Bonus ${rupiah(item.bonusAmount)} masuk ke toples Tabung!'
            : 'Status janji bonus diperbarui.',
      );
    } else {
      note(context, model.error ?? 'Belum bisa memperbarui janji bonus.');
    }
  }

  Color _statusColor(BonusStatus status) => switch (status) {
    BonusStatus.active => KColors.gold,
    BonusStatus.completed => KColors.mint,
    BonusStatus.failed => KColors.error,
  };

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    final items = model.bonuses;
    final tabung = model.currentTabung;
    return KPage(
      title: 'Bonus Tabungan',
      subtitle: widget.parentMode
          ? 'Berikan bonus jika anak menjaga tabungan utuh · Koini Plus'
          : 'Jaga tabunganmu tetap utuh untuk dapat bonus dari Ayah/Bunda!',
      children: [
        KCard(
          bright: true,
          child: Row(
            children: [
              const Illustration('piggy', size: 52),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    caption('Saldo toples Tabung saat ini'),
                    heading(rupiah(tabung), size: 24, color: KColors.mint),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(10),
        if (widget.parentMode) ...[
          KCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading('Buat janji bonus baru', size: 18),
                const Gap(8),
                KField(
                  'Minimal saldo tabungan (Rupiah)',
                  _minController,
                  numeric: true,
                  hint: '50000',
                  onChanged: model.setMinSavings,
                ),
                const Gap(8),
                KField(
                  'Nominal bonus (Rupiah)',
                  _bonusController,
                  numeric: true,
                  hint: '5000',
                  onChanged: model.setBonusAmount,
                ),
                const Gap(8),
                caption('Durasi menjaga tabungan'),
                const Gap(5),
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: [
                    for (final days in [7, 14, 30])
                      Pill(
                        '$days hari',
                        selected: model.durationDays == days,
                        onTap: () => model.setDurationDays(days),
                      ),
                  ],
                ),
                const Gap(10),
                KButton(
                  'Buat janji bonus',
                  small: true,
                  onTap: model.busy ? null : _create,
                ),
              ],
            ),
          ),
          const Gap(12),
        ],
        heading('Daftar janji bonus', size: 18),
        const Gap(6),
        if (items.isEmpty)
          KCallout(
            'Belum ada janji bonus',
            widget.parentMode
                ? 'Contoh: jika tabungan minimal Rp50.000 utuh 30 hari, Ayah tambah bonus Rp5.000.'
                : 'Ajak Ayah/Bunda membuat janji Bonus Tabungan di area orang tua.',
          ),
        for (final item in items) ...[
          Builder(
            builder: (context) {
              final met = tabung >= item.minSavings;
              final ratio = (tabung / item.minSavings).clamp(0.0, 1.0);
              return KCard(
                border: _statusColor(item.status),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: heading(
                            'Bonus ${rupiah(item.bonusAmount)}',
                            size: 19,
                            color: KColors.mint,
                          ),
                        ),
                        Pill(
                          item.status.label,
                          color: _statusColor(item.status),
                        ),
                      ],
                    ),
                    const Gap(4),
                    caption(
                      'Syarat minimal ${rupiah(item.minSavings)} · '
                      '${dateLabel(item.startDate)} s.d. ${dateLabel(item.endDate)}',
                    ),
                    const Gap(8),
                    GoalProgress(
                      ratio,
                      color: met ? KColors.mint : KColors.gold,
                    ),
                    const Gap(4),
                    caption(
                      met
                          ? 'Syarat saldo minimal terpenuhi!'
                          : 'Kurang ${rupiah(item.minSavings - tabung)} lagi untuk memenuhi syarat.',
                      color: met ? KColors.mint : KColors.soft,
                    ),
                    if (widget.parentMode &&
                        item.status == BonusStatus.active) ...[
                      const Gap(8),
                      Row(
                        children: [
                          Expanded(
                            child: KButton(
                              'Berikan bonus',
                              small: true,
                              onTap: model.busy
                                  ? null
                                  : () => _resolve(item, true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          KButton(
                            'Gagal',
                            small: true,
                            secondary: true,
                            onTap: model.busy
                                ? null
                                : () => _resolve(item, false),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const Gap(8),
        ],
      ],
    );
  }
}

@Preview(
  name: 'Bonus Tabungan (Orang tua)',
  group: 'Plus',
  size: koiniPreviewSize,
)
Widget savingsBonusPreview() => KoiniPreviewHost(
  page: (context, store) => SavingsBonusView(store: store, parentMode: true),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);

@Preview(name: 'Bonus Tabungan (Anak)', group: 'Plus', size: koiniPreviewSize)
Widget childSavingsBonusPreview() => KoiniPreviewHost(
  page: (context, store) => SavingsBonusView(store: store),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ChildShell(store: store),
);
