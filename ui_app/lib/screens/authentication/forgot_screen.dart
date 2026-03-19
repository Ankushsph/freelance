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
      final otp = await ApiService.sendOtp(
        email: _emailController.text.trim(),
        purpose: 'forgot_password',
      );

      if (!mounted) return;

      // Show OTP in a dialog for development
      if (otp != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('OTP Sent'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your OTP is:'),
                const SizedBox(height: 10),
                Text(
                  otp,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter this OTP on the next screen',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/otp',
                    arguments: {
                      'email': _emailController.text.trim(),
                      'purpose': 'forgot_password',
                    },
                  );
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      } else {
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {
            'email': _emailController.text.trim(),
            'purpose': 'forgot_password',
          },
        );
      }
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
                text: isLoading ? "Sending..." : "Send",
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