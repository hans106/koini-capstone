import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/dreams/widgets/dream_image.dart';
import 'package:koini/features/home/viewmodels/home_viewmodel.dart';
import 'package:koini/features/home/widgets/first_time_guide.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<HomeViewModel, HomeView>((ref, view) => HomeViewModel(view.store));

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key, required this.store, required this.parentAccess});
  final KoiniStore store;
  final VoidCallback parentAccess;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  KoiniStore get store => widget.store;
  late final _provider = _viewModelProvider(widget);
  HomeViewModel get model => ref.read(_provider);
  bool _checkedLeftover = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLeftoverJajan());
  }

  Future<void> _checkLeftoverJajan() async {
    if (_checkedLeftover || !mounted) return;
    _checkedLeftover = true;
    final moved = await model.sweepLeftoverJajan();
    if (!mounted || moved <= 0) return;
    await kSheet(
      context,
      'Sisa jajan masuk tabungan!',
      'Hore! ${rupiah(moved)} sisa jajanmu periode lalu otomatis pindah ke toples Tabung. '
          'Jangan lupa masukkan uang tunainya ke celengan, ya!',
    );
  }

  String _capitalize(String text) =>
      text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) {
    final dream = model.activeDream;
    final spent = model.spentThisWeek;
    final next = model.nextMission;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!model.tutorialDone) ...[
          KRow(
            'Panduan Koini (4 langkah)',
            'Baru pertama kali buka? Ketuk untuk melihat cara pakai.',
            color: KColors.gold,
            icon: const Icon(Icons.auto_awesome, color: KColors.gold),
            onTap: () =>
                showFirstTimeGuide(context, onComplete: model.completeTutorial),
          ),
          const Gap(10),
        ],
        KCard(
          bright: true,
          onTap: dream == null
              ? () => openPage(context, KRoute.createDream)
              : () => openPage(
                  context,
                  KRoute.dream,
                  pathParameters: {'id': dream.id},
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RASI IMPIANKU',
                style: TextStyle(
                  letterSpacing: 1.2,
                  color: KColors.gold,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(4),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading(dream?.name ?? 'Impian pertamamu', size: 24),
                        if (dream != null) ...[
                          const Gap(5),
                          heading(
                            rupiah(model.savedFor(dream)),
                            size: 29,
                            color: KColors.gold,
                          ),
                          Text('dari ${rupiah(dream.target)}'),
                        ] else
                          const Text('Pilih apa yang ingin kamu wujudkan.'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  if (dream != null)
                    dreamImage(dream)
                  else
                    const Illustration('bike', size: 76),
                ],
              ),
              Constellation(dream == null ? 0 : model.progress(dream)),
              if (dream != null)
                heading(
                  '${(model.progress(dream) * 100).round()}% tercapai · Kurang ${rupiah(model.remaining(dream))}',
                  size: 15,
                )
              else
                const Pill('Buat impian', selected: true),
            ],
          ),
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 7,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  heading('Uang sakuku', size: 20),
                  caption(
                    '${_capitalize(model.allowancePeriod.currentLabel)} ${rupiah(model.allowance)}',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            KButton('Atur', small: true, onTap: widget.parentAccess),
          ],
        ),
        const Gap(6),
        Row(
          children: [
            for (final jar in Jar.values) ...[
              if (jar != Jar.tabung) const SizedBox(width: 8),
              Expanded(
                child: KCard(
                  border: KColors.jar(jar),
                  padding: const EdgeInsets.all(9),
                  radius: 19,
                  onTap: () => openPage(
                    context,
                    KRoute.jar,
                    pathParameters: {'jar': jar.name},
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: heading(
                                jar.label,
                                size: 16,
                                color: KColors.jar(jar),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Illustration(jarArt(jar), size: 24),
                        ],
                      ),
                      const Gap(12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: heading(rupiah(model.balance(jar)), size: 21),
                      ),
                      const Gap(3),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const Gap(6),
        caption(
          'Total tiga toples ${rupiah(model.total)}',
          align: TextAlign.center,
        ),
        if (!model.receivedThisWeek) ...[
          const Gap(8),
          KRow(
            'Terima uang saku',
            'Catat setelah uang ${model.allowancePeriod.currentLabel} diterima.',
            color: KColors.gold,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                useRootNavigator: false,
                builder: (dialog) => AlertDialog(
                  title: heading('Uang saku sudah diterima?'),
                  content: Text(
                    '${rupiah(model.allowance)} akan dicatat dan dibagi ke tiga toples.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialog),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: const Text('Catat penerimaan'),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;
              if (model.busy) return;
              final received = await model.receiveAllowance();
              if (context.mounted) {
                note(
                  context,
                  received
                      ? 'Uang saku ${model.allowancePeriod.currentLabel} tercatat.'
                      : model.error!,
                );
              }
            },
          ),
        ],
        const Gap(11),
        KCard(
          onTap: () =>
              openPage(context, KRoute.quiz, pathParameters: {'id': next.id}),
          child: Row(
            children: [
              const Mascot(coin: false, size: 40),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    caption('Misi hari ini', color: KColors.gold),
                    heading(next.name, size: 18),
                    caption('Hingga 15 bintang belajar'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Pill('Main', selected: true),
            ],
          ),
        ),
        const Gap(9),
        KCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    caption(
                      'Jajan terpakai ${model.allowancePeriod.currentLabel}',
                    ),
                    heading(rupiah(spent), size: 23, color: KColors.peach),
                    caption('dari jatah ${rupiah(model.jajanAllocation)}'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              KButton(
                'Catat uang',
                small: true,
                onTap: () => openPage(context, KRoute.transaction),
              ),
            ],
          ),
        ),
        const Gap(9),
        KRow(
          'Cek celengan',
          'Hitung uang tunaimu dan cocokkan dengan catatan.',
          color: KColors.mint,
          onTap: () => openPage(context, KRoute.piggyCheck),
        ),
        const Gap(9),
        KRow(
          'Minggu ini',
          'Lihat ringkasan minggumu.',
          onTap: () => openPage(context, KRoute.weeklySummary),
        ),
      ],
    );
  }
}

@Preview(
  name: 'Beranda - saldo normal',
  group: 'Beranda',
  size: koiniPreviewSize,
)
Widget homePreview() =>
    KoiniPreviewHost(page: (context, store) => ChildShell(store: store));

@Preview(
  name: 'Beranda - saldo kosong',
  group: 'Beranda',
  size: koiniPreviewSize,
)
Widget emptyHomePreview() => KoiniPreviewHost(
  page: (context, store) => ChildShell(store: store),
  scenario: PreviewScenario.empty,
);

@Preview(name: 'Beranda - impian 40%', group: 'Beranda', size: koiniPreviewSize)
Widget dreamHomePreview() => KoiniPreviewHost(
  page: (context, store) => ChildShell(store: store),
  scenario: PreviewScenario.dream,
);

@Preview(
  name: 'Beranda - misi selesai',
  group: 'Beranda',
  size: koiniPreviewSize,
)
Widget completedHomePreview() => KoiniPreviewHost(
  page: (context, store) => ChildShell(store: store),
  scenario: PreviewScenario.missionsComplete,
);
