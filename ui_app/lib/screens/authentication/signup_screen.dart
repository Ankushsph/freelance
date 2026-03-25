import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/k_textfield.dart';
import '../../widgets/k_button.dart';
import '../../services/api_service.dart';
import '../../constants/auth_keys.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _signup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Send OTP to email
      final otpSent = await ApiService.sendOtp(
        email: _emailController.text.trim(),
        purpose: 'signup',
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(otpSent != null 
            ? "OTP sent to your email! Check your inbox.\nDev OTP: $otpSent" 
            : "OTP sent to your email! Check your inbox."),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );

      // Navigate to OTP screen
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {
          'email': _emailController.text.trim(),
          'purpose': 'signup',
          'userData': {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'number': int.parse(_mobileController.text.trim()),
            'password': _passwordController.text.trim(),
          },
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _signup,
          ),
        ),
      );
      
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 12),
              Text(
                "Let’s Konnect",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              KTextField(
                hint: "Name",
                icon: Icons.person_outline,
                controller: _nameController,
              ),
              const SizedBox(height: 14),
              KTextField(
                hint: "Email",
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 14),
              KTextField(
                hint: "Mobile No.",
                icon: Icons.phone_outlined,
                controller: _mobileController,
              ),
              const SizedBox(height: 14),
              KTextField(
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 20),
              KButton(
                text: isLoading ? "Creating Account..." : "Sign up",
                onTap: isLoading ? null : _signup,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an Account ? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}