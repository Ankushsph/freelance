import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/k_textfield.dart';
import '../../widgets/k_button.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Bypass OTP - directly navigate to password reset
      if (!mounted) return;
      
      Navigator.pushNamed(
        context,
        '/reset_pass',
        arguments: {
          'email': _emailController.text.trim(),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                "Enter Email",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              KTextField(
                hint: "Email",
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              KButton(
                text: isLoading ? "Processing..." : "Continue",
                onTap: isLoading ? null : _sendOtp,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}