import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'admin_dashboard.dart';
import 'student_dashboard.dart';
import 'faculty_dashboard.dart';
import '../config/api_config.dart';
import 'about_section.dart';
import 'registration_screen.dart'; // ✅ Added import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    setState(() => _isLoading = true);
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (id.isEmpty || password.isEmpty) {
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

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        dynamic data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final userData = data['data'];
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          } else if (role == 'student') {
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FacultyDashboard(
                  facultyId: int.parse(userData['faculty_id'].toString()),
                  facultyName: userData['name'],
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Login failed')),
          );
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2E0854),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Help & Support',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'For any assistance, please contact us at:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'anixandco123@gmail.com',
                      );
                      await launchUrl(emailUri);
                    },
                    child: const Text(
                      'anixandco123@gmail.com',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.language, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final Uri webUri = Uri.parse('https://anixandco.gt.tc/');
                      await launchUrl(
                        webUri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: const Text(
                      'Visit our website',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background animation
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final t = _bgController.value;
              final colors = [
                Color.lerp(
                  const Color(0xFF8E2DE2),
                  const Color(0xFF4A00E0),
                  t,
                )!,
                Color.lerp(
                  const Color(0xFF4A00E0),
                  const Color(0xFF00F0FF),
                  t,
                )!,
              ];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // Floating Bokeh
          ...List.generate(30, (index) {
            final rand = Random(index);
            final dx = rand.nextDouble() * size.width;
            final dy =
                (rand.nextDouble() * size.height +
                    (_bgController.value * size.height)) %
                size.height;
            final radius = rand.nextDouble() * 50 + 10;
            final opacity = 0.05 + rand.nextDouble() * 0.2;
            return Positioned(
              left: dx,
              top: dy,
              child: Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),

          // Help button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  onPressed: _showHelpDialog,
                  icon: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          // Login UI
          Column(
            children: [
              const Spacer(),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: min(size.width * 0.85, 400),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.school,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'ALLOXAM (beta version)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items: const [
                              DropdownMenuItem(
                                value: 'student',
                                child: Text('Student'),
                              ),
                              DropdownMenuItem(
                                value: 'faculty',
                                child: Text('Faculty'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => _selectedRole = val!),
                            dropdownColor: Colors.deepPurple,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _idController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: _selectedRole == 'faculty'
                                  ? 'Faculty Username'
                                  : 'Register / Admission / Username',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 40,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: loginUser,
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Register / Forgot Password',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'About App',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'ANIX & CO | ANTOLANZ PVT.LTD',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
