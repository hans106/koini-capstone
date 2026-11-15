import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/features/auth/views/account_entry.dart';
import 'package:koini/features/auth/views/login_view.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) => const AccountEntry(signUp: true);
}

@Preview(name: 'Daftar akun demo', group: 'Akun', size: koiniPreviewSize)
Widget signUpPreview() => KoiniPreviewHost(
  scenario: PreviewScenario.newProfile,
  page: (_, _) => const SignUpView(),
  returnPage: (_, _) => const LoginView(),
);
