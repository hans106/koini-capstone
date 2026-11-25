import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/viewmodels/parent_settings_viewmodel.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/widgets/rating_sheet.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ParentSettingsViewModel, ParentSettingsView>(
      (ref, view) => ParentSettingsViewModel(view.store),
    );

class ParentSettingsView extends ConsumerStatefulWidget {
  const ParentSettingsView({super.key, required this.store});
  final KoiniStore store;

  @override
  ConsumerState<ParentSettingsView> createState() => _ParentSettingsViewState();
}

class _ParentSettingsViewState extends ConsumerState<ParentSettingsView> {
  KoiniStore get store => widget.store;
  late final _provider = _viewModelProvider(widget);
  ParentSettingsViewModel get form => ref.read(_provider);

  Future<void> save() async {
    if (form.busy) return;
    final saved = await form.save();
    if (!mounted) return;
    note(context, saved ? 'Setelan orang tua tersimpan.' : form.error!);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return KPage(
      title: 'Setelan orang tua',
      subtitle: 'Dikelola oleh Ayah/Bunda',
      footer: KButton('Simpan setelan', onTap: form.busy ? null : save),
      children: [
        KRow(
          'Uang saku',
          '${rupiah(form.allowance)} ${form.allowancePeriod.perLabel} · Batas ${rupiah(form.dailyLimit)} per hari',
          onTap: () => openPage(context, KRoute.allowance),
        ),
        const Gap(8),
        KCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            title: const Text('Cerita Koini'),
            subtitle: caption('Cerita edukasi pilihan · Demo Koini Plus'),
            value: form.stories,
            onChanged: (value) {
              if (!form.hasPlus) {
                plusGate(
                  context,
                  yearly: false,
                  parentAccess: () => showPlus(context),
                );
              } else {
                form.setStories(value);
              }
            },
          ),
        ),
        const Gap(8),
        KRow(
          'Tambah bonus',
          'Catat uang bonus yang sudah diberikan',
          onTap: () => openPage(
            context,
            KRoute.transaction,
            extra: (
              kind: EntryKind.bonus,
              dream: null,
              source: null,
              destination: null,
            ),
          ),
        ),
        const Gap(7),
        KRow(
          'Ganti PIN',
          'PIN orang tua 6 digit',
          onTap: () => openPage(context, KRoute.changePin),
        ),
        const Gap(7),
        KRow(
          'Koini Plus',
          'Kelola pilihan pendampingan',
          onTap: () => showPlus(context),
        ),
        const Gap(7),
        KRow(
          'Beri nilai Koini',
          form.rating == 0
              ? 'Bantu kami menjadi lebih baik'
              : '${form.rating}/5 bintang',
          onTap: () => rate(context, store),
        ),
      ],
    );
  }
}

@Preview(name: 'Setelan orang tua', group: 'Orang tua', size: koiniPreviewSize)
Widget parentSettingsPreview() => KoiniPreviewHost(
  page: (context, store) => ParentSettingsView(store: store),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);
