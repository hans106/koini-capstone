import 'package:flutter/material.dart';

import '../theme/koini_theme.dart';

Widget heading(
  String text, {
  double size = 24,
  Color color = Colors.white,
  TextAlign? align,
  FontWeight weight = FontWeight.w800,
}) => Builder(
  builder: (context) => Text(
    text,
    textAlign: align,
    style: TextStyle(
      fontFamily: Theme.of(context).textTheme.headlineMedium?.fontFamily,
      fontSize: size,
      height: 1.14,
      fontWeight: weight,
      color: color,
    ),
  ),
);

Widget caption(String text, {Color color = KColors.text, TextAlign? align}) =>
    Text(
      text,
      textAlign: align,
      style: TextStyle(fontSize: 12, color: color),
    );

class Gap extends StatelessWidget {
  const Gap([this.size = 12, Key? key]) : super(key: key);
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}
