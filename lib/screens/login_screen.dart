import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_dashboard.dart'; // Import the real AdminDashboard
import 'student_dashboard.dart'; // Import the real StudentDashboard
import 'faculty_dashboard.dart'; // Import the new FacultyDashboard

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

  // PHP backend URL
  final String baseUrl =
      "http://192.168.1.35/exam_automation/login.php"; // replace with your server IP if needed

  Future<void> loginUser() async {
    setState(() => _isLoading = true);

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
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id': id, 'password': password, 'role': role},
      );

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
          } else if (role == 'student') {
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
          } else if (role == 'faculty') {
            // Navigate to the faculty dashboard, passing the faculty's ID.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FacultyDashboard(facultyId: id),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B0082), Color(0xFFFFD700)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Role selection
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: [
                const DropdownMenuItem(
                  value: 'student',
                  child: Text('Student'),
                ),
                const DropdownMenuItem(
                  value: 'faculty',
                  child: Text('Faculty'),
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

  // 🧭 Premium Role Selector UI
  Widget _buildRoleSelector() {
    final roles = [
      {'role': 'student', 'icon': Icons.school_rounded, 'label': 'Student'},
      {'role': 'faculty', 'icon': Icons.person_rounded, 'label': 'Faculty'},
      {
        'role': 'admin',
        'icon': Icons.admin_panel_settings_rounded,
        'label': 'Admin',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: roles.map((item) {
        final isSelected = _selectedRole == item['role'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedRole = item['role'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF6A0DAD), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSelected ? Colors.white : Colors.deepPurple.shade300,
                  size: 30,
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? Colors.white
                        : Colors.deepPurple.shade400,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 📋 Text field design
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.deepPurple.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
