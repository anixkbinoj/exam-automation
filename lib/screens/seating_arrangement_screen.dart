import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

    final url = Uri.parse(
      "http://10.159.50.69/exam_automation/get_seating.php",
    );

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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['exam_name'] ?? 'No Subject',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Date: ${item['exam_date'] ?? '-'}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            Text(
              "Hall: ${item['exam_hall'] ?? '-'}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            Text(
              "Room: ${item['room_no'] ?? '-'}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            Text(
              "Seat: ${item['seat_number'] ?? '-'}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            Text(
              "Department: ${item['department'] ?? '-'}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            Text(
              "Semester: ${item['semester'] ?? '-'}",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
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
                style: const TextStyle(fontSize: 16),
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
