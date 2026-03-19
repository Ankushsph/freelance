import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/k_button.dart';
import '../../services/api_service.dart';
import '../../constants/auth_keys.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
  List.generate(4, (_) => FocusNode());

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      for (int i = 0; i < value.length && i < 4; i++) {
        _controllers[i].text = value[i];
      }
      _focusNodes[3].requestFocus();
      return;
    }

    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String getOtp() {
    return _controllers.map((e) => e.text).join();
  }

  Future<void> _continue() async {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final otp = getOtp();
    final purpose = args['purpose'] ?? 'signup';

    try {

      await ApiService.verifyOtp(
        email: args['email'],
        otp: otp,
        purpose: purpose,
      );


      if (purpose == 'forgot_password') {

        if (!mounted) return;
        Navigator.pushNamed(
          context,
          '/reset-password',
          arguments: {
            'email': args['email'],
          },
        );
        return;
      }

      // Get user data from arguments
      final userData = args['userData'] as Map<String, dynamic>;

      final data = await ApiService.createUser(
        name: userData['name'],
        email: userData['email'],
        number: userData['number'],
        password: userData['password'],
      );


      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']!);
      await prefs.setString('user_name', data['name']!);
      await prefs.setString('user_email', data['email']!);
      await prefs.setString(AuthKeys.token, data['token']!);


      try {
        await ApiService.getMe();
      } catch (e) {

      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
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
              const Text(
                "Enter Verification Code",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                      (index) => SizedBox(
                    width: 55,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) => _onChanged(value, index),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              KButton(
                text: "Continue",
                onTap: _continue,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}