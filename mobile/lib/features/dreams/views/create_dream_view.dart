import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/dreams/controllers/dream_creation_controller.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class CreateDreamView extends StatefulWidget {
  const CreateDreamView({super.key, required this.store});
  final KoiniStore store;

  @override
  State<CreateDreamView> createState() => _CreateDreamViewState();
}

class _CreateDreamViewState extends State<CreateDreamView> {
  late final form = DreamCreationController(widget.store);

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> save() async {
    FocusScope.of(context).unfocus();
    final error = await form.save();
    if (!mounted) return;
    if (error != null) {
      await kSheet(context, 'Lengkapi impianmu', error, error: true);
      return;
    }
    await openPage<void>(
      context,
      Celebration(
        title: 'Impian tersimpan!',
        message:
            '${form.name.text.trim()}\nYuk, mulai menabung sedikit demi sedikit.',
        button: 'Selesai',
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: form, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) {
    final plan = form.plan;
    const labels = ['Buku', 'Sepeda', 'Game', 'Baju', 'Sepatu', 'Bola'];
    return KPage(
      title: 'Buat impian',
      footer: KButton('Simpan impian', onTap: form.busy ? null : save),
      children: [
        heading('Pilih gambar impian', size: 16),
        const Gap(6),
        for (var row = 0; row < 2; row++) ...[
          Row(
            children: [
              for (var i = row * 3; i < row * 3 + 3; i++) ...[
                if (i % 3 != 0) const SizedBox(width: 8),
                Expanded(
                  child: KCard(
                    border: i == form.image ? KColors.gold : null,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onTap: () => form.selectImage(i),
                    child: Center(
                      child: Tooltip(
                        message: labels[i],
                        child: Illustration(dreamArt[i], size: 57),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Gap(8),
        ],
        KField('Nama impian', form.name, hint: 'Buku komik', length: 32),
        const Gap(10),
        KField(
          'Harga target',
          form.target,
          numeric: true,
          hint: '100000',
          onChanged: (_) => form.refreshEstimate(),
        ),
        const Gap(10),
        heading('Tabungan mingguan', size: 16),
        const Gap(5),
        Wrap(
          spacing: 8,
          runSpacing: 5,
          children: [
            for (final value in [5000, 10000, 20000])
              Pill(
                rupiah(value),
                selected: value == form.weekly,
                onTap: () => form.selectWeekly(value),
              ),
          ],
        ),
        const Gap(),
        KCallout(
          'Sedikit demi sedikit',
          plan == null
              ? 'Isi harga untuk melihat perkiraannya.'
              : 'Jika menabung ${rupiah(form.weekly)} setiap minggu, impianmu tercapai dalam ${plan.weeks} minggu.',
        ),
      ],
    );
  }
}

@Preview(
  name: 'Buat impian dan ubah target',
  group: 'Impian',
  size: koiniPreviewSize,
)
Widget createDreamPreview() => KoiniPreviewHost(
  page: (context, store) => CreateDreamView(store: store),
  scenario: PreviewScenario.dream,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.dreams),
);
