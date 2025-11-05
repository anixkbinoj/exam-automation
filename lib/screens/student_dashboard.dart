import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'seating_arrangement_screen.dart';
import 'exam_timetable_screen.dart';
import 'view_notices_screen.dart';
import 'view_faculty_screen.dart';
import 'login_screen.dart';
import '../config/api_config.dart';

class StudentDashboard extends StatefulWidget {
  final String registerNumber;
  final String admissionNumber;

  const StudentDashboard({
    super.key,
    required this.registerNumber,
    required this.admissionNumber,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with TickerProviderStateMixin {
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  String _errorMessage = '';

  late AnimationController _bgController;
  late AnimationController _fadeController;
  late AnimationController _buttonPulseController;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    fetchStudentDetails();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _fadeController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  Future<void> fetchStudentDetails() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.fetchStudentDetails),
        body: {
          'register_number': widget.registerNumber,
          'admission_number': widget.admissionNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            studentData = data['student'];
          });
          _fadeController.forward();
        } else {
          setState(() => _errorMessage = data['message']);
        }
      } else {
        setState(() => _errorMessage = 'Server error.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Student Dashboard"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final t = _bgController.value;
              final colors = [
                Color.lerp(const Color(0xFF8E2DE2), const Color(0xFF4A00E0), t)!,
                Color.lerp(const Color(0xFF240046), const Color(0xFF5A189A), 1 - t)!,
                Color.lerp(const Color(0xFF3C096C), const Color(0xFF9D4EDD), t)!,
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

          // Floating glowing particles
          ...List.generate(45, (index) {
            final rand = Random(index);
            final dx = rand.nextDouble() * size.width;
            final dy =
                (rand.nextDouble() * size.height + (_bgController.value * size.height)) %
                    size.height;
            final radius = rand.nextDouble() * 2 + 1;
            final opacity = 0.15 + rand.nextDouble() * 0.25;
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

          // Main dashboard content
          isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
              : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : FadeTransition(
            opacity: _fadeController,
            child: _buildDashboardContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 60),
          const SizedBox(height: 10),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
            ),
            onPressed: fetchStudentDetails,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${studentData?['name'] ?? 'Student'} 👋",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.cyanAccent.withOpacity(0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Let's ace your exams 🎯",
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(),
          const SizedBox(height: 30),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  Widget _buildInfoCard() {
    return _buildGlassCard(
      child: Column(
        children: [
          _infoRow("Admission No", studentData?['admission_number']),
          _infoRow("Register No", studentData?['register_number']),
          _infoRow("Department", studentData?['department']),
          _infoRow("Class", studentData?['class']),
          _infoRow("Semester", studentData?['semester']),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value ?? 'N/A',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final buttons = [
      {
        'text': '🎟 View Seating Arrangement',
        'page': SeatingArrangementPage(
          registerNumber: widget.registerNumber,
          admissionNumber: widget.admissionNumber,
        ),
        'gradient': [Colors.cyanAccent, Colors.indigoAccent],
      },
      {
        'text': '📅 View Exam Timetable',
        'page': const ExamTimeTableScreen(),
        'gradient': [Colors.orangeAccent, Colors.pinkAccent],
      },
      {
        'text': '📢 View Notices',
        'page': const ViewNoticesScreen(),
        'gradient': [Colors.tealAccent, Colors.blueAccent],
      },
      {
        'text': '👨‍🏫 View Teachers',
        'page': const ViewFacultyScreen(),
        'gradient': [Colors.purpleAccent, Colors.deepPurpleAccent],
      },
    ];

    return Column(
      children: buttons.map((btn) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AnimatedBuilder(
            animation: _buttonPulseController,
            builder: (context, child) => Transform.scale(
              scale: _buttonPulseController.value,
              child: child,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => btn['page'] as Widget),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: btn['gradient'] as List<Color>,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    btn['text'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
