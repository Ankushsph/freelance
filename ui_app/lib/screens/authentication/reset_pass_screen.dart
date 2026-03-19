import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/k_textfield.dart';
import '../../widgets/k_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();

  Future<void> _reset() async {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    await ApiService.resetPassword(
      email: args['email'],
      newPassword: _passwordController.text.trim(),
    );

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KTextField(
              hint: "New Password",
              icon: Icons.lock_outline,
              obscure: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 20),
            KButton(text: "Reset Password", onTap: _reset),
          ],
        ),
      ),
    );
  }
}