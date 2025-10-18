import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  String _role = 'student'; // default

  void _login() {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your ${_role == 'student' ? 'Register / Admission Number' : 'Admin ID'}',
          ),
        ),
      );
      return;
    }

    if (_role == 'admin') {
      // For simplicity, using a hardcoded admin ID.
      // In a real app, this should be a secure authentication check.
      if (id == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid Admin ID')));
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDashboard(registerNumber: id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Automation Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) => setState(() => _role = value!),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: _role == 'student'
                      ? 'Register / Admission Number'
                      : 'Admin ID',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}
