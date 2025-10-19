import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'admin_dashboard.dart';
import 'student_dashboard.dart';
import 'faculty_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;

  final String baseUrl = "http://10.3.2.145/exam_automation/login.php";

  Future<void> loginUser() async {
    setState(() => _isLoading = true);

    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter ID and password')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id': id, 'password': password, 'role': role},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Login Successful!')));

          final userData = data['data'];

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          } else if (role == 'student') {
            // Pass register_number from PHP data
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentDashboard(
                  registerNumber: userData['register_number'],
                  admissionNumber: userData['admission_number'] ?? '',
                ),
              ),
            );
          } else if (role == 'faculty') {
            // Pass faculty ID and name
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FacultyDashboard(
                  facultyId: int.parse(userData['id'].toString()),
                  facultyName: userData['name'],
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server Error: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Automation Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'faculty', child: Text('Faculty')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() => _selectedRole = value!);
              },
              decoration: const InputDecoration(
                labelText: 'Select Role',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: _selectedRole == 'faculty'
                    ? 'Faculty Name'
                    : 'Register / Admission / Username',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: loginUser,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
