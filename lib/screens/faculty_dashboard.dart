import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

class _FacultyDashboardState extends State<FacultyDashboard> with TickerProviderStateMixin {
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
      debugPrint("📤 Sending faculty_id: ${widget.facultyId}");

      final dutiesResponse = await http.post(
        Uri.parse(ApiConfig.fetchAssignedDuties),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'faculty_id': widget.facultyId.toString()},
      );

      final noticesResponse = await http.get(Uri.parse(ApiConfig.getNotices));

      debugPrint("✅ Duties Response: ${dutiesResponse.body}");
      debugPrint("✅ Notices Response: ${noticesResponse.body}");

      if (!mounted) return;

      final dutiesData = jsonDecode(dutiesResponse.body);
      final noticesData = jsonDecode(noticesResponse.body);

      setState(() {
        if (dutiesData['status'] == 'success') {
          duties = dutiesData['data'];
        } else {
          duties = [];
        }

        notices = noticesData is List ? noticesData : [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "⚠️ Error fetching data: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _openFile(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open file: $url");
    }
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 60),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: fetchDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10),
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
                  "👋 Welcome, ${widget.facultyName}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Here's your dashboard 📋",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildGlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.assignment_outlined, color: Colors.blueAccent),
                  title: Text("Total Duties: ${duties.length}", style: const TextStyle(color: Colors.white)),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orangeAccent),
                  title: Text("Total Notices: ${notices.length}", style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final buttons = [
      {
        'text': '📋 View Assigned Duties',
        'page': FacultyDutiesPage(duties: duties),
        'gradient': [Colors.cyanAccent, Colors.indigoAccent],
      },
      {
        'text': '📢 View Notices',
        'page': FacultyNoticesPage(notices: notices),
        'gradient': [Colors.orangeAccent, Colors.pinkAccent],
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
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: btn['gradient'] as List<Color>),
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
                    style: const TextStyle(
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
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Faculty Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final t = _bgController.value;
              final colors = [
                Color.lerp(Colors.blueAccent, Colors.indigo, t)!,
                Color.lerp(Colors.deepPurple, Colors.purpleAccent, 1 - t)!,
                Color.lerp(Colors.purple, Colors.pinkAccent, t)!,
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
            final dy = (rand.nextDouble() * size.height + (_bgController.value * size.height)) % size.height;
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
              : FadeTransition(opacity: _fadeController..forward(), child: _buildDashboardContent()),
        ],
      ),
    );
  }
}
