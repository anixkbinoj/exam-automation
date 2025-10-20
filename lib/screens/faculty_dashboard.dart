import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:exam_automation/config/api_config.dart';
import 'package:http/http.dart' as http;

// Screens for detailed pages
import 'faculty_duties_page.dart';
import 'view_notices_screen.dart';

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

class _FacultyDashboardState extends State<FacultyDashboard> {
  bool isLoading = true;
  List<dynamic> duties = [];
  List<dynamic> notices = [];
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      _errorMessage = '';
    });

    try {
      final dutiesResponse = await http.post(
        Uri.parse(ApiConfig.fetchAssignedDuties),
        body: {'faculty_id': widget.facultyId.toString()},
      );

      final noticesResponse = await http.get(Uri.parse(ApiConfig.getNotices));

      if (!mounted) return;

      setState(() {
        duties = jsonDecode(dutiesResponse.body);
        notices = jsonDecode(noticesResponse.body);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Error fetching data: $e";
      });
      debugPrint("Error fetching data: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          "Faculty Dashboard",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchDashboardData,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: fetchDashboardData,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${widget.facultyName} 👋",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Buttons
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.assignment),
                          label: const Text("View Assigned Duties"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(250, 50),
                            backgroundColor: const Color(0xFF2563EB),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FacultyDutiesPage(duties: duties),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.notifications_active),
                          label: const Text("View Notices"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(250, 50),
                            backgroundColor: const Color(0xFFF59E0B),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ViewNoticesScreen(notices: notices),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
