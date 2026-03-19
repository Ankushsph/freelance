import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BoostSheet extends StatefulWidget {
  const BoostSheet({super.key});

  @override
  State<BoostSheet> createState() => _BoostSheetState();
}

class _BoostSheetState extends State<BoostSheet> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController messageController = TextEditingController();

  bool isLoading = false;

  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  late final String boostUrl = "$baseUrl/boost/send";
  late final String userUrl = "$baseUrl/users/me";

  String? authToken;
  Map<String, dynamic>? userData;

  
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  
  Future<void> fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('jwt_token');

      if (authToken == null) throw "Token Missing";

      final res = await http.get(
        Uri.parse(userUrl),
        headers: {
          "Authorization": "Bearer $authToken",
        },
      );

      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            userData = jsonDecode(res.body);
          });
        }
      } else {
        throw "User fetch failed";
      }
    } catch (e) {
      if (mounted) {
        _showSnack("Error: $e");
      }
    }
  }

  
  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  
  Future<void> pickTime() async {
    final now = DateTime.now();
    final initialTime = TimeOfDay(
      hour: (now.hour + 1) % 24, // Default to 1 hour from now
      minute: now.minute,
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  
  Future<void> sendBoostRequest() async {
    if (selectedDate == null || selectedTime == null) {
      _showSnack("Select date & time ⏰");
      return;
    }

    // Validate that the selected date/time is not in the past
    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final now = DateTime.now();
    if (dateTime.isBefore(now)) {
      _showSnack("Cannot book past time slots ⏰");
      return;
    }

    // Additional check: if it's today, ensure the time is at least 1 hour from now
    if (selectedDate!.year == now.year && 
        selectedDate!.month == now.month && 
        selectedDate!.day == now.day) {
      final oneHourFromNow = now.add(const Duration(hours: 1));
      if (dateTime.isBefore(oneHourFromNow)) {
        _showSnack("Please book at least 1 hour in advance ⏰");
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('jwt_token');

      if (authToken == null) throw "Unauthorized";

      final res = await http.post(
        Uri.parse(boostUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({
          "userId": userData?['id'] ?? userData?['_id'],
          "name": userData?['name'],
          "contact": userData?['email'],
          "timeSlot": dateTime.toIso8601String(),
          "message": messageController.text.trim().isNotEmpty ? messageController.text.trim() : null,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          _showSnack("Slot Booked ✅");
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          _showSnack(data['message'] ?? "Failed");
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack("Error: $e");
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,

        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black26,
              )
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              /// HEADER
              Row(
                children: [

                  const Text(
                    "Expert Connect",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// DATE
              _pickerTile(
                icon: Icons.calendar_today,
                title: "Date",
                value: selectedDate == null
                    ? "Select date"
                    : DateFormat('dd MMM yyyy')
                    .format(selectedDate!),
                onTap: pickDate,
              ),

              const SizedBox(height: 15),

              /// TIME
              _pickerTile(
                icon: Icons.access_time,
                title: "Time",
                value: selectedTime == null
                    ? "Select time"
                    : selectedTime!.format(context),
                onTap: pickTime,
              ),

              const SizedBox(height: 15),

              /// MESSAGE
              _messageBox(),

              const SizedBox(height: 25),

              /// BUTTON
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  onPressed:
                  isLoading ? null : sendBoostRequest,

                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Book a Slot",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _pickerTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),

        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8),
        ),

        child: Row(
          children: [

            Icon(icon, size: 20, color: Colors.blueAccent),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    value,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _messageBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: messageController,
        maxLines: 3,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Write a message for the expert...",
          icon: Icon(Icons.chat_bubble_outline, color: Colors.blueAccent),
        ),
      ),
    );
  }

  
  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }
}