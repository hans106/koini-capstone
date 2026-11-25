import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/jars/viewmodels/piggy_check_viewmodel.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<PiggyCheckViewModel, PiggyCheckView>(
      (ref, view) => PiggyCheckViewModel(view.store),
    );

class PiggyCheckView extends ConsumerStatefulWidget {
  const PiggyCheckView({super.key, required this.store});
  final KoiniStore store;

  @override
  ConsumerState<PiggyCheckView> createState() => _PiggyCheckViewState();
}

class _PiggyCheckViewState extends ConsumerState<PiggyCheckView> {
  late final _provider = _viewModelProvider(widget);
  PiggyCheckViewModel get model => ref.read(_provider);

  Future<void> _save() async {
    final saved = await model.save();
    if (!mounted) return;
    if (!saved) {
      note(context, model.error ?? 'Belum bisa menyimpan hasil cek celengan.');
      return;
    }
    final check = model.lastSaved;
    if (check == null) return;
    final diff = check.difference;
    final title = diff == 0
        ? 'Pas! Catatanmu cocok!'
        : diff > 0
        ? 'Uang tunaimu lebih ${rupiah(diff)}'
        : 'Selisih kurang ${rupiah(diff.abs())}';
    final message = diff == 0
        ? 'Hebat! Uang tunai di celengan sama persis dengan catatan Koini (${rupiah(check.recordedAmount)}).'
        : diff > 0
        ? 'Ada ${rupiah(diff)} uang fisik yang mungkin belum kamu catat sebagai uang masuk.'
        : 'Ada ${rupiah(diff.abs())} yang mungkin sempat terpakai jajan tapi belum dicatat.';
    await kSheet(context, title, message);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    final diff = model.difference;
    final diffColor = !model.hasInput
        ? KColors.soft
        : diff == 0
        ? KColors.mint
        : diff > 0
        ? KColors.gold
        : KColors.error;
    final diffLabel = !model.hasInput
        ? 'Hitung uang fisikmu lalu ketik jumlahnya di bawah.'
        : diff == 0
        ? 'Selisih Rp0 · Cocok dengan catatan!'
        : diff > 0
        ? 'Lebih ${rupiah(diff)} dari catatan Koini'
        : 'Kurang ${rupiah(diff.abs())} dari catatan Koini';

    return KPage(
      title: 'Cek celengan',
      subtitle: 'Cocokkan uang tunaimu dengan catatan Koini',
      footer: KButton(
        'Simpan hasil cek',
        onTap: model.busy || !model.hasInput ? null : _save,
      ),
      children: [
        KCard(
          bright: true,
          child: Column(
            children: [
              const Illustration('piggy', size: 64),
              const Gap(6),
              caption('Total catatan Koini (3 toples)'),
              heading(
                rupiah(model.recordedTotal),
                size: 30,
                color: KColors.mint,
              ),
              const Gap(4),
              caption(
                'Tabung ${rupiah(model.tabungBalance)} · '
                'Jajan ${rupiah(model.jajanBalance)} · '
                'Berbagi ${rupiah(model.berbagiBalance)}',
                align: TextAlign.center,
              ),
            ],
          ),
        ),
        const Gap(10),
        KCard(
          border: diffColor,
          child: Column(
            children: [
              caption('Uang tunai yang kamu hitung'),
              heading(
                rupiah(model.physicalAmount),
                size: 32,
                color: KColors.gold,
              ),
              const Gap(4),
              caption(diffLabel, color: diffColor, align: TextAlign.center),
            ],
          ),
        ),
        const Gap(10),
        Keypad(onDigit: model.enterDigit),
        if (model.history.isNotEmpty) ...[
          const Gap(14),
          heading('Riwayat cek celengan', size: 18),
          const Gap(6),
          for (final item in model.history.take(5)) ...[
            KRow(
              'Fisik ${rupiah(item.physicalAmount)}',
              'Catatan ${rupiah(item.recordedAmount)} · ${dateLabel(item.checkedAt)}',
              trailing: heading(
                item.difference == 0
                    ? 'Pas'
                    : '${item.difference > 0 ? '+' : ''}${rupiah(item.difference)}',
                size: 14,
                color: item.difference == 0
                    ? KColors.mint
                    : item.difference > 0
                    ? KColors.gold
                    : KColors.error,
              ),
            ),
            const Gap(6),
          ],
        ],
      ],
    );
  }
}

@Preview(name: 'Cek celengan', group: 'Toples', size: koiniPreviewSize)
Widget piggyCheckPreview() => KoiniPreviewHost(
  page: (context, store) => PiggyCheckView(store: store),
  returnPage: (context, store) => ChildShell(store: store),
);
