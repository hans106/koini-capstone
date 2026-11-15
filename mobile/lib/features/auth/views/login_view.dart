import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/features/auth/views/account_entry.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) => const AccountEntry(signUp: false);
}

@Preview(name: 'Masuk akun demo', group: 'Akun', size: koiniPreviewSize)
Widget loginPreview() => KoiniPreviewHost(
  scenario: PreviewScenario.newProfile,
  page: (_, _) => const LoginView(),
);
