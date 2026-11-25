import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/plus/viewmodels/reward_challenge_viewmodel.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<RewardChallengeViewModel, RewardChallengeView>(
      (ref, view) =>
          RewardChallengeViewModel(view.store, parentMode: view.parentMode),
    );

class RewardChallengeView extends ConsumerStatefulWidget {
  const RewardChallengeView({
    super.key,
    required this.store,
    this.parentMode = false,
  });

  final KoiniStore store;
  final bool parentMode;

  @override
  ConsumerState<RewardChallengeView> createState() =>
      _RewardChallengeViewState();
}

class _RewardChallengeViewState extends ConsumerState<RewardChallengeView> {
  final _titleController = TextEditingController();
  final _reqController = TextEditingController();
  final _rewardController = TextEditingController(text: '10000');

  late final _provider = _viewModelProvider(widget);
  RewardChallengeViewModel get model => ref.read(_provider);

  @override
  void dispose() {
    _titleController.dispose();
    _reqController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    FocusScope.of(context).unfocus();
    final ok = await model.create();
    if (!mounted) return;
    if (ok) {
      _titleController.clear();
      _reqController.clear();
      _rewardController.text = '10000';
      model
        ..setTitle('')
        ..setRequirement('')
        ..setReward('10000');
      note(context, 'Tantangan Hadiah berhasil dibuat!');
    } else {
      note(context, model.error ?? 'Periksa data tantangan.');
    }
  }

  Future<void> _resolve(RewardChallenge item, bool succeeded) async {
    final ok = await model.confirm(item.id, succeeded: succeeded);
    if (!mounted) return;
    if (ok) {
      note(
        context,
        succeeded
            ? 'Hadiah ${rupiah(item.reward)} tercatat ke toples Tabung!'
            : 'Status tantangan diperbarui.',
      );
    } else {
      note(context, model.error ?? 'Gagal memperbarui tantangan.');
    }
  }

  Color _statusColor(ChallengeStatus status) => switch (status) {
    ChallengeStatus.active => KColors.gold,
    ChallengeStatus.waiting => KColors.peach,
    ChallengeStatus.completed => KColors.mint,
    ChallengeStatus.failed => KColors.error,
  };

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    final items = model.challenges;
    return KPage(
      title: 'Tantangan Hadiah',
      subtitle: widget.parentMode
          ? 'Buat tantangan & konfirmasi hadiah ke tabungan anak · Koini Plus'
          : 'Selesaikan tantangan dari Ayah/Bunda untuk tambah tabungan!',
      children: [
        if (widget.parentMode) ...[
          KCard(
            bright: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading('Buat tantangan baru', size: 18),
                const Gap(8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final kind in ChallengeKind.values)
                      Pill(
                        kind.label,
                        selected: model.kind == kind,
                        onTap: () => model.setKind(kind),
                      ),
                  ],
                ),
                const Gap(8),
                KField(
                  'Judul tantangan',
                  _titleController,
                  hint: 'Contoh: Nilai Matematika >= 90',
                  length: 80,
                  onChanged: model.setTitle,
                ),
                const Gap(8),
                KField(
                  'Syarat',
                  _reqController,
                  hint: 'Tunjukkan hasil ulangan ke Ayah/Bunda',
                  length: 120,
                  onChanged: model.setRequirement,
                ),
                const Gap(8),
                KField(
                  'Hadiah (Rupiah)',
                  _rewardController,
                  numeric: true,
                  hint: '10000',
                  onChanged: model.setReward,
                ),
                const Gap(10),
                KButton(
                  'Tambah tantangan',
                  small: true,
                  onTap: model.busy ? null : _create,
                ),
              ],
            ),
          ),
          const Gap(12),
        ],
        heading('Daftar tantangan', size: 18),
        const Gap(6),
        if (items.isEmpty)
          KCallout(
            'Belum ada tantangan',
            widget.parentMode
                ? 'Buat tantangan pertamamu di atas, misalnya hadiah nilai ujian atau tugas rumah.'
                : 'Ajak Ayah/Bunda membuat Tantangan Hadiah di area orang tua.',
          ),
        for (final item in items) ...[
          KCard(
            border: _statusColor(item.status),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: heading(item.title, size: 17)),
                    Pill(item.status.label, color: _statusColor(item.status)),
                  ],
                ),
                const Gap(4),
                caption('${item.kind.label} · ${item.requirement}'),
                const Gap(6),
                Row(
                  children: [
                    heading(rupiah(item.reward), size: 19, color: KColors.mint),
                    const SizedBox(width: 8),
                    if (model.dreamName(item.dreamId) case final dreamName?)
                      Expanded(
                        child: caption(
                          'Untuk impian: $dreamName',
                          align: TextAlign.end,
                        ),
                      ),
                  ],
                ),
                if (!widget.parentMode &&
                    item.status == ChallengeStatus.active) ...[
                  const Gap(8),
                  KButton(
                    'Aku sudah selesai!',
                    small: true,
                    onTap: model.busy
                        ? null
                        : () async {
                            final ok = await model.markWaiting(item.id);
                            if (context.mounted && ok) {
                              note(
                                context,
                                'Sip! Minta Ayah/Bunda mengonfirmasi di area orang tua.',
                              );
                            }
                          },
                  ),
                ],
                if (widget.parentMode &&
                    (item.status == ChallengeStatus.active ||
                        item.status == ChallengeStatus.waiting)) ...[
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: KButton(
                          'Konfirmasi berhasil',
                          small: true,
                          onTap: model.busy ? null : () => _resolve(item, true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      KButton(
                        'Belum',
                        small: true,
                        secondary: true,
                        onTap: model.busy ? null : () => _resolve(item, false),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Gap(8),
        ],
      ],
    );
  }
}

@Preview(
  name: 'Tantangan Hadiah (Orang tua)',
  group: 'Plus',
  size: koiniPreviewSize,
)
Widget rewardChallengePreview() => KoiniPreviewHost(
  page: (context, store) => RewardChallengeView(store: store, parentMode: true),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);

@Preview(name: 'Tantangan Hadiah (Anak)', group: 'Plus', size: koiniPreviewSize)
Widget childRewardChallengePreview() => KoiniPreviewHost(
  page: (context, store) => RewardChallengeView(store: store),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ChildShell(store: store),
);
