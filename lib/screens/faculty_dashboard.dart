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

class _FacultyDashboardState extends State<FacultyDashboard> {
  List<dynamic> duties = [];
  List<dynamic> notices = [];
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
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
          Text(message,
              style: const TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: fetchDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Dashboard layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Dashboard"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildError(_errorMessage)
          : RefreshIndicator(
        onRefresh: fetchDashboardData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              "👋 Welcome, ${widget.facultyName}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Buttons to navigate
            ElevatedButton.icon(
              icon: const Icon(Icons.assignment),
              label: const Text("View Assigned Duties"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FacultyDutiesPage(duties: duties),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.notifications),
              label: const Text("View Notices"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FacultyNoticesPage(notices: notices),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Summary counts
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: const Icon(Icons.assignment_outlined,
                    color: Colors.blueAccent),
                title: Text("Total Duties: ${duties.length}"),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: const Icon(Icons.notifications_active,
                    color: Colors.orangeAccent),
                title: Text("Total Notices: ${notices.length}"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
