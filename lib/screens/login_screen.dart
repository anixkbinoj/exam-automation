import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_dashboard.dart'; // Import the real AdminDashboard
import 'student_dashboard.dart'; // Import the real StudentDashboard
import 'faculty_dashboard.dart'; // Import the new FacultyDashboard
import '../config/api_config.dart'; // Use the centralized API config
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> loginUser() async {
    setState(() => _isLoading = true);

    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (id.isEmpty || password.isEmpty) {
      // No mounted check needed here as it's not in an async gap
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ID and password')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id': id, 'password': password, 'role': role},
      );

      // Crucial check after an async operation
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // The SnackBar was removed as it would not be visible before navigation.

          // Navigate based on role
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          } else if (role == 'student') {
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
            // Assuming login response includes faculty_name
            final facultyName = data['faculty_name'] as String? ?? 'Faculty';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FacultyDashboard(
                  facultyId: int.tryParse(id) ?? 0,
                  facultyName: facultyName,
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    // Only update state if the widget is still mounted (i.e., login failed)
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isWeb ? 400 : double.infinity,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRoleSelector(),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _idController,
                    label: _selectedRole == 'student'
                        ? 'Register / Admission No'
                        : 'Username',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : _buildLoginButton(),
                ],
              ),
            ),
          ),
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

  // ✨ Premium Login Button
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: loginUser,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: Colors.deepPurple.withOpacity(0.5),
      ),
      child: Text(
        'Login',
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
      ),
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
