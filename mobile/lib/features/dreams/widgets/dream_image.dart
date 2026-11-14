import 'package:flutter/material.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/models/koini_data.dart';

Widget dreamImage(Dream dream, {double size = 78}) =>
    Illustration(dreamArt[dream.image], size: size);
