import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/utils/keypad_value.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/previews/preview_host.dart';

class ParentPinView extends StatefulWidget {
  const ParentPinView({
    super.key,
    required this.title,
    required this.prompt,
    required this.verify,
    this.recovery = false,
    this.onVerified,
    this.buttonLabel = 'Buka ringkasan',
  });

  final String title;
  final String prompt;
  final Future<String?> Function(String) verify;
  final bool recovery;
  final String buttonLabel;
  final VoidCallback? onVerified;

  @override
  State<ParentPinView> createState() => _ParentPinViewState();
}

class _ParentPinViewState extends State<ParentPinView> {
  String code = '';
  String? error;
  bool busy = false;

  Future<void> submit() async {
    if (busy) return;
    if (code.length != 6) {
      setState(() => error = 'Masukkan 6 angka PIN.');
      return;
    }
    setState(() => busy = true);
    final problem = await widget.verify(code);
    if (!mounted) return;
    if (problem == null) {
      if (widget.onVerified case final onVerified?) {
        setState(() {
          code = '';
          busy = false;
        });
        onVerified();
      } else {
        Navigator.pop(context, true);
      }
    } else {
      setState(() {
        error = problem;
        code = '';
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => KPage(
    title: widget.title,
    footer: KButton(widget.buttonLabel, onTap: busy ? null : submit),
    children: [
      KCard(
        bright: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('Khusus Ayah/Bunda', size: 18, color: KColors.gold),
            Text(widget.prompt),
          ],
        ),
      ),
      const Gap(17),
      PinDots(count: code.length),
      const Gap(9),
      caption(
        error ?? 'PIN tersimpan di HP ini.',
        color: error == null ? KColors.text : KColors.error,
        align: TextAlign.center,
      ),
      const Gap(),
      Keypad(
        pin: true,
        onDigit: (key) {
          if (!busy) {
            setState(() {
              code = keypadValue(code, key, 6);
              error = null;
            });
          }
        },
      ),
      if (widget.recovery)
        Center(
          child: TextButton(
            onPressed: () => kSheet(
              context,
              'Lupa PIN?',
              'Pemulihan melalui email belum tersedia dalam mode demo.',
            ),
            child: const Text('Lupa PIN?'),
          ),
        ),
    ],
  );
}

@Preview(
  name: 'Masuk dengan PIN demo 123456',
  group: 'Orang tua',
  size: koiniPreviewSize,
)
Widget parentPinPreview() => KoiniPreviewHost(
  page: (context, store) => ParentPinView(
    title: 'PIN orang tua',
    prompt: 'Masukkan PIN 6 digit untuk membuka pengawasan di HP ini.',
    verify: (pin) async => store.checkPin(pin),
    recovery: true,
    onVerified: () => openPage(context, ParentDashboardView(store: store)),
  ),
  returnPage: (_, store) =>
      ChildShell(store: store, initialTab: ChildTab.profile),
);
