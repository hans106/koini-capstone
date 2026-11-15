import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/jars/widgets/jar_split_editor.dart';
import 'package:koini/features/parents/viewmodels/allowance_settings_viewmodel.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class AllowanceSettingsView extends StatefulWidget {
  const AllowanceSettingsView({super.key, required this.store});
  final KoiniStore store;

  @override
  State<AllowanceSettingsView> createState() => _AllowanceSettingsViewState();
}

class _AllowanceSettingsViewState extends State<AllowanceSettingsView> {
  late final form = AllowanceSettingsViewModel(widget.store);

  late final amountField = TextEditingController(text: form.total.toString());
  late final limitField = TextEditingController(text: form.limit.toString());

  @override
  void dispose() {
    amountField.dispose();
    limitField.dispose();
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: form, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) => KPage(
    title: 'Atur uang saku',
    footer: KButton(
      'Simpan rencana',
      onTap: form.busy
          ? null
          : () async {
              if (form.busy) return;
              final saved = await form.save();
              if (!context.mounted) return;
              if (saved) {
                Navigator.pop(context);
                note(context, 'Rencana uang saku tersimpan.');
              } else {
                note(context, form.error!);
              }
            },
    ),
    children: [
      KField(
        'Nominal per minggu',
        amountField,
        numeric: true,
        onChanged: form.changeAmount,
      ),
      const Gap(8),
      KField(
        'Batas jajan harian',
        limitField,
        numeric: true,
        onChanged: form.changeLimit,
      ),
      const Gap(10),
      JarSplitEditor(
        key: ValueKey(form.total),
        amount: form.total,
        initial: form.split,
        onChanged: form.changeSplit,
      ),
      const Gap(8),
      caption('Rencana berlaku pada penerimaan uang saku berikutnya.'),
    ],
  );
}

@Preview(name: 'Atur uang saku', group: 'Orang tua', size: koiniPreviewSize)
Widget allowanceSettingsPreview() => KoiniPreviewHost(
  page: (context, store) => AllowanceSettingsView(store: store),
  returnPage: (context, store) => ParentDashboardView(store: store),
);
