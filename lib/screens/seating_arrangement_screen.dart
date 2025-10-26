import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SeatingArrangementPage extends StatefulWidget {
  final String registerNumber;
  final String admissionNumber;

  const SeatingArrangementPage({
    Key? key,
    required this.registerNumber,
    required this.admissionNumber,
  }) : super(key: key);

  @override
  State<SeatingArrangementPage> createState() => _SeatingArrangementPageState();
}

class _SeatingArrangementPageState extends State<SeatingArrangementPage> {
  List<Map<String, dynamic>> seatingData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSeating();
  }

  Future<void> fetchSeating() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      seatingData = [];
    });

    final url = Uri.parse(ApiConfig.getSeating);

    try {
      final response = await http.post(
        url,
        body: {
          "register_number": widget.registerNumber.trim(),
          "admission_number": widget.admissionNumber.trim(),
        },
      );

      if (!mounted) return;

      debugPrint("Server response: ${response.body}");

      final data = jsonDecode(response.body);

      if (data['status'] == 'success' && data['seating'] != null) {
        final List seatingList = data['seating'];
        if (seatingList.isEmpty) {
          errorMessage = 'No seating arrangement found for your number.';
        } else {
          seatingData = List<Map<String, dynamic>>.from(seatingList);
        }
      } else {
        errorMessage = data['message'] ?? 'No seating arrangement found';
      }
    } catch (e) {
      debugPrint("Failed to fetch seating: $e");
      errorMessage =
          'Failed to fetch seating arrangement. Please check your connection.';
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildExamCard(Map<String, dynamic> item) {
    // This UI is merged from the redundant 'student_seating_screen.dart' for a better look.
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.deepPurpleAccent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['exam_name'] ?? 'No Subject',
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_today, "Date", item['exam_date']),
            _buildDetailRow(Icons.location_on, "Hall", item['exam_hall']),
            _buildDetailRow(Icons.meeting_room, "Room", item['room_no']),
            _buildDetailRow(
              Icons.confirmation_number,
              "Seat",
              item['seat_number'],
            ),
            _buildDetailRow(Icons.school, "Department", item['department']),
            _buildDetailRow(Icons.layers, "Semester", item['semester']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.deepPurple.shade300),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Seating Arrangement"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: fetchSeating,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : seatingData.isEmpty
          ? Center(
              child: Text(
                errorMessage.isNotEmpty ? errorMessage : "No data available",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: seatingData.length,
              itemBuilder: (context, index) {
                return _buildExamCard(seatingData[index]);
              },
            ),
    );
  }
}
