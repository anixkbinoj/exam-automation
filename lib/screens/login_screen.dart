import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'admin_dashboard.dart';
import 'student_dashboard.dart';
import 'faculty_dashboard.dart';
import '../config/api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = "Admin"; // Default role

  final List<String> roles = ["Admin", "Faculty", "Student"];

  Future<void> _loginUser() async {
    if (_idController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Please enter ID and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        body: {
          'id': _idController.text.trim(),
          'password': _passwordController.text.trim(),
          'role': _selectedRole.toLowerCase(),
        },
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        _showSnackBar("Login Successful!");
        final userData = data['data'];

        if (_selectedRole == "Admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else if (_selectedRole == "Student") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDashboard(
                registerNumber: userData['register_number'],
                admissionNumber: userData['admission_number'] ?? '',
              ),
            ),
          );
        } else if (_selectedRole == "Faculty") {
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
        _showSnackBar(data['message'] ?? "Login failed. Please try again.");
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("An error occurred. Please check your connection.");
      debugPrint("Login Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.2, -0.2),
            radius: 1.2,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "LOGIN",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.blueAccent.withOpacity(0.7),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Role Selection
                _buildRoleSelector(),

                const SizedBox(height: 30),

                // Username Field
                _buildTextField(
                  controller: _idController,
                  hintText: "ID / Username / Email",
                  icon: Icons.person,
                  obscure: false,
                ),
                const SizedBox(height: 20),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  icon: Icons.lock,
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // Login Button
                GestureDetector(
                  onTap: _isLoading ? null : _loginUser,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.cyanAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.6),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "LOGIN AS $_selectedRole",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Role Selector Widget
  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: roles.map((role) {
          bool isSelected = _selectedRole == role;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRole = role;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blueAccent.withOpacity(0.8)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.6),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                role,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.cyanAccent,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}
