import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'upload_seating_screen.dart';
import 'allot_teacher_screen.dart';
import 'upload_notices_screen.dart';
import 'upload_timetable_screen.dart';
import 'view_reports_screen.dart';
import 'login_screen.dart';
import 'add_student_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _bgController;

  final List<Map<String, dynamic>> actions = [
    {
      'icon': Icons.upload_file,
      'label': 'Seating',
      'color': Colors.blueAccent,
      'page': const UploadSeatingScreen(),
    },
    {
      'icon': Icons.assignment_ind,
      'label': 'Duties',
      'color': Colors.purpleAccent,
      'page': const AllotTeacherScreen(),
    },
    {
      'icon': Icons.notifications_active,
      'label': 'Notices',
      'color': Colors.orangeAccent,
      'page': const UploadNoticesScreen(),
    },
    {
      'icon': Icons.table_chart,
      'label': 'Timetable',
      'color': Colors.greenAccent,
      'page': const UploadTimeTableScreen(),
    },
    {
      'icon': Icons.person_add,
      'label': 'Students',
      'color': Colors.pinkAccent,
      'page': const AddStudentScreen(),
    },
    {
      'icon': Icons.bar_chart,
      'label': 'Reports',
      'color': Colors.cyanAccent,
      'page': const ViewReportsScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
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
          // Layer 1: Animated Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      sin(_bgController.value * 2 * pi),
                      cos(_bgController.value * 2 * pi),
                    ),
                    radius: 1.5,
                    colors: const [
                      Color(0xFF0F2027),
                      Color(0xFF203A43),
                      Color(0xFF2C5364),
                    ],
                  ),
                ),
              );
            },
          ),
          // Layer 2: Foreground Content
          // Use a SizedBox to make the Stack fill the screen, allowing Positioned to work correctly.
          SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Center Circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "ADMIN",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.blueAccent.withOpacity(0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Orbit Buttons
                ...List.generate(actions.length, (i) {
                  return AnimatedBuilder(
                    animation: _orbitController,
                    builder: (context, _) {
                      final angle =
                          (i / actions.length) * 2 * pi +
                          _orbitController.value * 2 * pi;
                      final radius = 180.0;
                      final scale = 0.9 + 0.2 * (0.5 + 0.5 * sin(angle));

                      // Use Positioned to correctly handle layout and hit-testing in a Stack.
                      // We calculate left/top from the center of the Stack.
                      // The button's own size (120x120) is used to center it on the calculated point.
                      return Positioned(
                        left: (size.width / 2) + (cos(angle) * radius) - 60,
                        top:
                            (size.height / 2) +
                            (sin(angle) * radius * 0.6) -
                            60,
                        child: Transform.scale(
                          scale: scale,
                          child: GestureDetector(
                            onTap: () {
                              final label = actions[i]['label'];
                              if (label == 'Timetable' || label == 'Reports') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'This feature is coming soon!',
                                    ),
                                    backgroundColor: Colors.blueGrey,
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => actions[i]['page'],
                                  ),
                                );
                              }
                            },
                            child: _orbitButton(
                              icon: actions[i]['icon'],
                              color: actions[i]['color'],
                              label: actions[i]['label'],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orbitButton({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Opacity(
          opacity: (label == 'Timetable' || label == 'Reports') ? 0.5 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.7),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.8),
                      color.withOpacity(0.6),
                      Colors.white.withOpacity(0.1),
                    ],
                    center: const Alignment(-0.2, -0.2),
                    radius: 0.8,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
