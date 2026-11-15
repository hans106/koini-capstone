import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/viewmodels/parent_settings_viewmodel.dart';
import 'package:koini/features/parents/views/allowance_settings_view.dart';
import 'package:koini/features/parents/views/change_pin_view.dart';
import 'package:koini/features/parents/views/email_preview_view.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/parents/widgets/rating_sheet.dart';
import 'package:koini/features/plus/views/gift_season_view.dart';
import 'package:koini/features/transactions/views/add_transaction_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class ParentSettingsView extends StatefulWidget {
  const ParentSettingsView({super.key, required this.store});
  final KoiniStore store;

  @override
  State<ParentSettingsView> createState() => _ParentSettingsViewState();
}

class _ParentSettingsViewState extends State<ParentSettingsView> {
  KoiniStore get store => widget.store;
  late final form = ParentSettingsViewModel(store);

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (form.busy) return;
    final saved = await form.save();
    if (!mounted) return;
    note(context, saved ? 'Setelan orang tua tersimpan.' : form.error!);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: form,
    builder: (context, _) => KPage(
      title: 'Setelan orang tua',
      subtitle: 'Dikelola oleh Ayah/Bunda',
      footer: KButton('Simpan setelan', onTap: form.busy ? null : save),
      children: [
        KRow(
          'Uang saku',
          '${rupiah(form.allowance)} per minggu Â· Batas ${rupiah(form.dailyLimit)} per hari',
          onTap: () => openPage(context, AllowanceSettingsView(store: store)),
        ),
        const Gap(8),
        KCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading('Email Ayah/Bunda', size: 17),
                          caption(
                            form.email.isEmpty
                                ? 'Email belum diisi'
                                : form.email,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    KButton(
                      'Lihat contoh',
                      small: true,
                      onTap: () =>
                          openPage(context, EmailPreviewView(store: store)),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Ringkasan mingguan'),
                subtitle: caption('Preferensi demo'),
                value: form.reminders,
                onChanged: form.setReminders,
              ),
            ],
          ),
        ),
        const Gap(8),
        KCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            title: const Text('Cerita Koini'),
            subtitle: caption('Cerita edukasi pilihan Â· Demo Koini Plus'),
            value: form.stories,
            onChanged: (value) {
              if (!form.hasPlus) {
                plusGate(
                  context,
                  yearly: false,
                  parentAccess: () => showPlus(context, store),
                );
              } else {
                form.setStories(value);
              }
            },
          ),
        ),
        const Gap(8),
        KRow(
          'Musim uang hadiah',
          'THR, angpao, dan hadiah Â· Tahunan',
          onTap: () => openYearly(
            context,
            store,
            () => openPage(context, GiftSeasonView(store: store)),
          ),
        ),
        const Gap(7),
        KRow(
          'Peringatan email',
          'Kabar saat catatan tabungan berkurang Â· Tahunan',
          onTap: () => openYearly(
            context,
            store,
            () =>
                openPage(context, EmailPreviewView(store: store, alert: true)),
          ),
        ),
        const Gap(7),
        KRow(
          'Tambah bonus',
          'Catat uang bonus yang sudah diberikan',
          onTap: () => openPage(
            context,
            AddTransactionView(store: store, kind: EntryKind.bonus),
          ),
        ),
        const Gap(7),
        KRow(
          'Ganti PIN',
          'PIN orang tua 6 digit',
          onTap: () => openPage(context, ChangePinView(store: store)),
        ),
        const Gap(7),
        KRow(
          'Koini Plus',
          'Kelola pilihan pendampingan',
          onTap: () => showPlus(context, store),
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
    ),
  );
}

@Preview(name: 'Setelan orang tua', group: 'Orang tua', size: koiniPreviewSize)
Widget parentSettingsPreview() => KoiniPreviewHost(
  page: (context, store) => ParentSettingsView(store: store),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);
