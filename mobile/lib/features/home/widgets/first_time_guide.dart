import 'package:flutter/material.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';

class _GuideStep {
  const _GuideStep(this.title, this.body, this.icon);
  final String title;
  final String body;
  final IconData icon;
}

const _steps = [
  _GuideStep(
    '1. Kenali 3 Toples',
    'Uang sakumu dibagi ke Tabung (untuk impian), Jajan (kebutuhan harian), dan Berbagi (membantu sesama).',
    Icons.savings_rounded,
  ),
  _GuideStep(
    '2. Catat Uang & Sisa Jajan',
    'Catat setiap jajan dan uang masuk. Di akhir periode, sisa jajanmu otomatis pindah ke Tabung!',
    Icons.edit_note_rounded,
  ),
  _GuideStep(
    '3. Impian & Cek Celengan',
    'Pasang target barang impianmu, lalu rutin pakai Cek Celengan supaya uang tunai fisik cocok dengan catatan.',
    Icons.star_rounded,
  ),
  _GuideStep(
    '4. Main Misi & Area Orang Tua',
    'Kumpulkan bintang lewat kuis cerita OJK. Area pengawasan Ayah/Bunda aman di balik PIN 6 angka.',
    Icons.lock_outline_rounded,
  ),
];

class FirstTimeGuideCard extends StatefulWidget {
  const FirstTimeGuideCard({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<FirstTimeGuideCard> createState() => _FirstTimeGuideCardState();
}

class _FirstTimeGuideCardState extends State<FirstTimeGuideCard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    final isLast = _index == _steps.length - 1;
    return KCard(
      border: KColors.gold,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(step.icon, color: KColors.gold, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: caption(
                  'PANDUAN KOINI · ${_index + 1} DARI ${_steps.length}',
                  color: KColors.gold,
                ),
              ),
              TextButton(
                onPressed: widget.onComplete,
                child: const Text('Lewati'),
              ),
            ],
          ),
          heading(step.title, size: 18),
          const Gap(4),
          Text(step.body),
          const Gap(10),
          Row(
            children: [
              if (_index > 0) ...[
                KButton(
                  'Kembali',
                  small: true,
                  secondary: true,
                  onTap: () => setState(() => _index--),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: KButton(
                  isLast ? 'Selesai panduan' : 'Langkah berikutnya',
                  small: true,
                  onTap: isLast
                      ? widget.onComplete
                      : () => setState(() => _index++),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showFirstTimeGuide(
  BuildContext context, {
  VoidCallback? onComplete,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (sheetContext) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: FirstTimeGuideCard(
        onComplete: () {
          Navigator.pop(sheetContext);
          onComplete?.call();
        },
      ),
    ),
  ),
);
