import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeatingArrangementScreen extends StatelessWidget {
  const SeatingArrangementScreen({super.key});

  final List<Map<String, String>> dummyData = const [
    {"subject": "Maths", "hall": "Hall A", "seatNo": "A12"},
    {"subject": "Physics", "hall": "Hall B", "seatNo": "B07"},
    {"subject": "Chemistry", "hall": "Hall C", "seatNo": "C05"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seating Arrangement"),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyData.length,
        itemBuilder: (context, index) {
          final item = dummyData[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.event_seat, color: Color(0xFF2563EB)),
              title: Text(
                item["subject"]!,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "Hall: ${item["hall"]}\nSeat: ${item["seatNo"]}",
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          );
        },
      ),
    );
  }
}
