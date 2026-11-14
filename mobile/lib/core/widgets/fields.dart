import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controls.dart';
import 'text.dart';

class KField extends StatelessWidget {
  const KField(
    this.label,
    this.controller, {
    super.key,
    this.hint,
    this.length,
    this.numeric = false,
    this.secret = false,
    this.email = false,
    this.onChanged,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int? length;
  final bool numeric;
  final bool secret;
  final bool email;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
      const Gap(5),
      TextField(
        controller: controller,
        obscureText: secret,
        onChanged: onChanged,
        keyboardType: numeric
            ? TextInputType.number
            : email
            ? TextInputType.emailAddress
            : TextInputType.text,
        textCapitalization: numeric || email
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        inputFormatters: [
          if (numeric) FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(length ?? (numeric ? 9 : 80)),
        ],
        decoration: InputDecoration(
          hintText: hint,
          prefixText: numeric && !secret ? 'Rp ' : null,
        ),
      ),
    ],
  );
}

class Keypad extends StatelessWidget {
  const Keypad({super.key, required this.onDigit, this.pin = false});
  final ValueChanged<String> onDigit;
  final bool pin;

  @override
  Widget build(BuildContext context) {
    final keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      pin ? '' : '000',
      '0',
      'Hapus',
    ];
    return Column(
      children: [
        for (var row = 0; row < 4; row++) ...[
          if (row > 0) const Gap(8),
          Row(
            children: [
              for (var col = 0; col < 3; col++) ...[
                if (col > 0) const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: keys[row * 3 + col].isEmpty
                        ? null
                        : KCard(
                            bright: true,
                            radius: 15,
                            padding: EdgeInsets.zero,
                            onTap: () => onDigit(keys[row * 3 + col]),
                            child: Center(
                              child: heading(keys[row * 3 + col], size: 21),
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
