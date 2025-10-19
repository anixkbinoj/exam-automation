import 'package:flutter/material.dart';
import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http;
import 'admin_dashboard.dart'; // Import the real AdminDashboard
import 'student_dashboard.dart'; // Import the real StudentDashboard

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'student'; // default role
  bool _isLoading = false;

  // PHP backend URL
  final String baseUrl =
      "http://192.168.1.35/exam_automation/login.php"; // replace with your server IP if needed

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter ID and password')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id': id, 'password': password, 'role': role},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Login Successful!')));

          // Navigate based on role
          if (role == 'admin') {
            // The existing AdminDashboard doesn't take data, so we just navigate.
            // You can modify AdminDashboard later to use the logged-in admin's data.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          } else {
            // The existing StudentDashboard expects a registerNumber.
            // We'll pass the student's ID from the successful login.
            // Assuming your PHP login response includes 'admission_number' for students.
            final admissionNumber = data['admission_number'] as String? ?? '';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentDashboard(
                  registerNumber: id,
                  admissionNumber: admissionNumber,
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Automation Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Role selection
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: [
                const DropdownMenuItem(
                  value: 'student',
                  child: Text('Student'),
                ),
                const DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Role',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ID input
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: _selectedRole == 'student'
                    ? 'Register / Admission / Username'
                    : 'Username',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password input
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Login button
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
