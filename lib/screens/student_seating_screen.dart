import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class StudentSeatingScreen extends StatefulWidget {
  final String registerNumber;
  final String admissionNumber;

  const StudentSeatingScreen({
    super.key,
    required this.registerNumber,
    required this.admissionNumber,
  });

  @override
  State<StudentSeatingScreen> createState() => _StudentSeatingScreenState();
}

class _StudentSeatingScreenState extends State<StudentSeatingScreen> {
  List<Map<String, dynamic>> _exams = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSeatingArrangement();
  }

  Future<void> _fetchSeatingArrangement() async {
    var uri = Uri.parse('http://10.159.50.69/exam_automation/get_seating.php');

    try {
      var response = await http.post(
        uri,
        body: {
          'register_number': widget.registerNumber,
          'admission_number': widget.admissionNumber,
        },
      );

      if (!mounted) return;

      var data = json.decode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _exams = List<Map<String, dynamic>>.from(data['seating'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'No schedule found';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching seating arrangement: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.deepPurpleAccent),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam['exam_name'] ?? 'No Subject',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Date: ${exam['exam_date'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Hall: ${exam['exam_hall'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.meeting_room, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Room: ${exam['room_no'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.confirmation_number,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  'Seat: ${exam['seat_number'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
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
        title: const Text('My Seating Arrangement'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          : _exams.isEmpty
          ? const Center(
              child: Text(
                'No seating arrangement found',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _exams.length,
              itemBuilder: (context, index) {
                return _buildExamCard(_exams[index]);
              },
            ),
    );
  }
}
