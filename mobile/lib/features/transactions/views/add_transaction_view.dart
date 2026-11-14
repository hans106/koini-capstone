import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/transactions/controllers/transaction_controller.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({
    super.key,
    required this.store,
    this.kind = EntryKind.spend,
    this.dream,
    this.destination,
    this.source,
  });
  final KoiniStore store;
  final EntryKind kind;
  final Dream? dream;
  final Jar? destination;
  final Jar? source;

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final memo = TextEditingController();
  late final form = TransactionController(
    widget.store,
    kind: widget.kind,
    dream: widget.dream,
    destination: widget.destination,
    source: widget.source,
  );
  KoiniStore get store => widget.store;
  EntryKind get kind => form.kind;
  Dream? get dream => form.dream;
  int get amount => form.amount;

  @override
  void dispose() {
    memo.dispose();
    form.dispose();
    super.dispose();
  }

  Future<void> save() async {
    FocusScope.of(context).unfocus();
    if (amount == 0) {
      await kSheet(
        context,
        'Nominalnya masih kosong',
        'Ketik dulu jumlah uangnya, ya.',
      );
      return;
    }
    final error = await form.save(memo.text);
    if (!mounted) return;
    if (error != null) {
      await kSheet(
        context,
        'Periksa nominalnya',
        error,
        primary: 'Ubah nominal',
        error: true,
      );
      return;
    }
    final completed = form.completed;
    await openPage<void>(
      context,
      Celebration(
        header: completed ? 'Impian tercapai' : null,
        title: completed ? 'Hore, kamu berhasil!' : 'Tersimpan!',
        message: completed
            ? 'Kamu sudah tekun menabung. Ajak Ayah/Bunda untuk melihat catatan impianmu.'
            : '${kind.label} ${rupiah(amount)}\nKoini hanya mencatat uang saku.',
        details: completed
            ? [
                KCard(
                  border: KColors.gold,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading(dream!.name, size: 19),
                      caption(rupiah(store.savedFor(dream!))),
                      const Gap(9),
                      const GoalProgress(1, color: KColors.mint),
                    ],
                  ),
                ),
                const Gap(),
                const KCallout(
                  'Saatnya ajak Ayah/Bunda',
                  'Lihat impianmu bersama dan tentukan langkah selanjutnya.',
                ),
              ]
            : [],
        button: completed ? 'Kembali ke impian' : 'Selesai',
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Widget jarPicker(String label, Jar selected, ValueChanged<Jar> choose) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          caption(label),
          const Gap(5),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final jar in Jar.values)
                Pill(
                  jar.label,
                  selected: selected == jar,
                  color: KColors.jar(jar),
                  onTap: () => choose(jar),
                ),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: form, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) {
    final spending = store.amountFor(EntryKind.spend, store.thisWeek);
    final options = [
      EntryKind.spend,
      EntryKind.save,
      EntryKind.give,
      EntryKind.income,
      EntryKind.transfer,
    ];
    return KPage(
      title: kind == EntryKind.bonus ? 'Catat bonus' : 'Catat uangmu',
      footer: KButton('Simpan', onTap: form.busy ? null : save),
      children: [
        if (widget.kind != EntryKind.bonus && widget.dream == null) ...[
          caption('Pilih kategori'),
          const Gap(6),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final option in options)
                Pill(
                  option.label,
                  selected: kind == option,
                  onTap: () => form.chooseKind(option),
                ),
            ],
          ),
          const Gap(10),
        ],
        KCard(
          bright: true,
          child: Row(
            children: [
              const Expanded(child: Text('Nominal')),
              heading(rupiah(amount), size: 30, color: KColors.gold),
            ],
          ),
        ),
        const Gap(8),
        KField('Catatan (opsional)', memo, hint: kind.label),
        const Gap(10),
        Keypad(onDigit: form.enterDigit),
        const Gap(12),
        if (kind == EntryKind.spend) ...[
          KCard(
            border: KColors.peach,
            child: caption(
              'Jajan terpakai ${rupiah(spending)} minggu ini.\nSisa toples Jajan ${rupiah(store.balance(Jar.jajan))}.',
              color: KColors.peach,
            ),
          ),
          if (store.hasPlus) ...[
            const Gap(9),
            caption('Kategori pengeluaran'),
            const Gap(6),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final name in categories)
                  Pill(
                    name,
                    selected: form.category == name,
                    onTap: () => form.chooseCategory(name),
                  ),
              ],
            ),
          ],
        ],
        if (kind == EntryKind.give)
          caption(
            'Sisa toples Berbagi ${rupiah(store.balance(Jar.berbagi))}.',
            color: KColors.lavender,
          ),
        if (kind == EntryKind.transfer) ...[
          jarPicker('Dari toples', form.source, form.chooseSource),
          const Gap(8),
        ],
        if (kind == EntryKind.income ||
            kind == EntryKind.transfer ||
            kind == EntryKind.bonus)
          jarPicker('Ke toples', form.destination, form.chooseDestination),
        if (kind == EntryKind.save) ...[
          caption('Tujuan tabungan'),
          const Gap(5),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (widget.dream == null)
                Pill(
                  'Toples Tabung',
                  selected: dream == null,
                  onTap: () => form.chooseDream(null),
                ),
              for (final item
                  in widget.dream == null
                      ? store.dreams.where((item) => store.remaining(item) > 0)
                      : [widget.dream!])
                Pill(
                  item.name,
                  selected: dream?.id == item.id,
                  onTap: () => form.chooseDream(item),
                ),
            ],
          ),
          if (dream != null) ...[
            const Gap(8),
            caption('Sumber tabungan'),
            const Gap(5),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Pill(
                  'Uang tunai baru',
                  selected: form.savingSource == null,
                  onTap: () => form.chooseSavingSource(null),
                ),
                for (final jar in Jar.values)
                  Pill(
                    jar.label,
                    selected: form.savingSource == jar,
                    onTap: () => form.chooseSavingSource(jar),
                  ),
              ],
            ),
            const Gap(5),
            caption(
              'Tabung yang belum dibagi ${rupiah(store.availableSavings)}.',
            ),
          ],
        ],
      ],
    );
  }
}

@Preview(name: 'Catat transaksi', group: 'Transaksi', size: koiniPreviewSize)
Widget transactionPreview() => KoiniPreviewHost(
  page: (context, store) => AddTransactionView(store: store),
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.history),
);

@Preview(
  name: 'Catat transaksi - saldo kurang',
  group: 'Transaksi',
  size: koiniPreviewSize,
)
Widget lowBalancePreview() => KoiniPreviewHost(
  page: (context, store) => AddTransactionView(store: store),
  scenario: PreviewScenario.lowBalance,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.history),
);
