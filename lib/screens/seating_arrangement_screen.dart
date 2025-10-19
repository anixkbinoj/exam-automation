import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class SeatingArrangementPage extends StatefulWidget {
  final String registerNumber;
  final String admissionNumber;

  const SeatingArrangementPage({
    super.key,
    required this.registerNumber,
    required this.admissionNumber,
  });

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
    final url = Uri.parse(
      "http://192.168.1.35/exam_automation/get_seating.php",
    ); // Change to your server IP

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "register_number": widget.registerNumber,
          "admission_number": widget.admissionNumber,
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final List temp = data['seating'];
        // Cast to the correct type to avoid runtime errors.
        seatingData = List<Map<String, dynamic>>.from(temp);
      } else {
        errorMessage = data['message'] ?? 'No seating data found';
      }
    } catch (e) {
      errorMessage = 'Failed to fetch seating arrangement';
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seating Arrangement"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : seatingData.isEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: seatingData.length,
              itemBuilder: (context, index) {
                final item = seatingData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.event_seat,
                      color: Colors.deepPurple,
                    ),
                    title: Text(
                      item['exam_name']?.toString() ?? 'No Subject',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Hall: ${item['room_number']}\nSeat: ${item['seat_number']}\nDate: ${item['exam_date']}\nTime: ${item['exam_time']}",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
