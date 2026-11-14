import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class ChangePinView extends StatefulWidget {
  const ChangePinView({super.key, required this.store});
  final KoiniStore store;

  @override
  State<ChangePinView> createState() => _ChangePinViewState();
}

class _ChangePinViewState extends State<ChangePinView> {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KPage(
    title: 'Ganti PIN',
    footer: KButton(
      'Simpan PIN',
      onTap: busy
          ? null
          : () async {
              if (current.text.length != 6 ||
                  next.text.length != 6 ||
                  next.text != confirm.text) {
                note(context, 'Isi PIN lama dan ulangi PIN baru 6 angka.');
                return;
              }
              setState(() => busy = true);
              final error = await widget.store.updatePin(
                current.text,
                next.text,
              );
              if (!context.mounted) return;
              if (error != null) {
                setState(() => busy = false);
                note(context, error);
              } else {
                Navigator.pop(context);
                note(context, 'PIN baru tersimpan.');
              }
            },
    ),
    children: [
      KField('PIN lama', current, numeric: true, secret: true, length: 6),
      const Gap(10),
      KField('PIN baru', next, numeric: true, secret: true, length: 6),
      const Gap(10),
      KField(
        'Ulangi PIN baru',
        confirm,
        numeric: true,
        secret: true,
        length: 6,
      ),
    ],
  );
}

@Preview(
  name: 'Ganti PIN demo 123456',
  group: 'Orang tua',
  size: koiniPreviewSize,
)
Widget changePinPreview() => KoiniPreviewHost(
  page: (context, store) => ChangePinView(store: store),
  returnPage: (context, store) => ParentDashboardView(store: store),
);
