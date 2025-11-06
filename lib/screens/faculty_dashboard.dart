import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import 'faculty_duties_page.dart';
import 'faculty_notices_page.dart';

class FacultyDashboard extends StatefulWidget {
  final int facultyId;
  final String facultyName;

  const FacultyDashboard({
    super.key,
    required this.facultyId,
    required this.facultyName,
  });

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard>
    with TickerProviderStateMixin {
  List<dynamic> duties = [];
  List<dynamic> notices = [];
  String _errorMessage = '';
  bool _isLoading = true;

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

    fetchDashboardData();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _fadeController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final dutiesResponse = await http.post(
        Uri.parse(ApiConfig.fetchAssignedDuties),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'faculty_id': widget.facultyId.toString()},
      );

      final noticesResponse =
      await http.get(Uri.parse(ApiConfig.getNotices));

      dynamic dutiesData = dutiesResponse.body.isNotEmpty
          ? jsonDecode(dutiesResponse.body)
          : {};
      dynamic noticesData = noticesResponse.body.isNotEmpty
          ? jsonDecode(noticesResponse.body)
          : {};

      setState(() {
        duties = (dutiesData is Map &&
            dutiesData['status'] == 'success' &&
            dutiesData['data'] is List)
            ? dutiesData['data']
            : [];

        notices = (noticesData is Map && noticesData['status'] == 'success')
            ? noticesData['data']
            : [];

        _fadeController.forward();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "⚠️ $e";
        _isLoading = false;
      });
    }
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Faculty Dashboard"),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Animated background
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
                (rand.nextDouble() * size.height +
                    (_bgController.value * size.height)) %
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

          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _errorMessage.isNotEmpty
              ? _buildError(_errorMessage)
              : FadeTransition(
            opacity: _fadeController,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _glassCard(
                    child: Text(
                      "Welcome, ${widget.facultyName} 👋",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Action Buttons
                  _actionButton(
                    text: "📌 View Assigned Duties",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FacultyDutiesPage(duties: duties),
                      ),
                    ),
                    gradient: const [Colors.cyanAccent, Colors.indigoAccent],
                  ),
                  _actionButton(
                    text: "📢 View Notices",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FacultyNoticesPage(notices: notices),
                      ),
                    ),
                    gradient: const [Colors.orangeAccent, Colors.pinkAccent],
                  ),
                  const SizedBox(height: 25),

                  // Summary
                  _glassCard(
                    child: Column(
                      children: [
                        _summaryRow("Total Duties", duties.length.toString()),
                        _summaryRow("Total Notices", notices.length.toString()),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: AnimatedBuilder(
        animation: _buttonPulseController,
        builder: (context, child) => Transform.scale(
          scale: _buttonPulseController.value,
          child: child,
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
