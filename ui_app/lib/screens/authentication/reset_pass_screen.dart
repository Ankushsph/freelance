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
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password required")),
      );
      return;
    }

    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    try {
      await ApiService.resetPassword(
        email: args['email'],
        newPassword: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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