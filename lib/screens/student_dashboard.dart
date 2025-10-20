import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'seating_arrangement_screen.dart'; // Import the new screen
import 'exam_timetable_screen.dart'; // Placeholder for timetable
import 'view_notices_screen.dart'; // Placeholder for notices
import 'login_screen.dart'; // For logout navigation

class StudentDashboard extends StatefulWidget {
  final String registerNumber;
  final String admissionNumber;

  const StudentDashboard({
    super.key,
    required this.registerNumber,
    required this.admissionNumber,
  });

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  final String apiUrl =
      "http://10.159.50.69/exam_automation/fetch_student_details.php";

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  Future<void> fetchStudentDetails() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
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
            isLoading = false;
          });
        } else {
          showError(data['message']);
        }
      } else {
        showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error: $e");
    }
  }

  void showError(String message) {
    if (!mounted) return; // Check if the widget is still in the tree
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text('Student Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentData == null
          ? const Center(child: Text('No data found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Welcome, ${studentData!['name']}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Student info card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          infoRow(
                            "Admission No",
                            studentData!['admission_number'],
                          ),
                          infoRow(
                            "Register No",
                            studentData!['register_number'],
                          ),
                          infoRow("Department", studentData!['department']),
                          infoRow("Class", studentData!['class']),
                          infoRow("Semester", studentData!['semester']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Action Buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDashboardButton(
                        context,
                        text: "View Seating Arrangement",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SeatingArrangementPage(
                                registerNumber: widget.registerNumber,
                                admissionNumber: widget.admissionNumber,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDashboardButton(
                        context,
                        text: "View Exam Time Table",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExamTimeTableScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDashboardButton(
                        context,
                        text: "View Notices",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ViewNoticesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
