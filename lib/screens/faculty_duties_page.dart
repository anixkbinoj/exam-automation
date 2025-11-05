import 'package:flutter/material.dart';

class FacultyDutiesPage extends StatelessWidget {
  final List<dynamic> duties;

  const FacultyDutiesPage({super.key, required this.duties});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Duties"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: duties.isEmpty
          ? const Center(
        child: Text(
          "No assigned duties yet.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: duties.length,
        itemBuilder: (context, index) {
          final duty = duties[index];
          final subject = duty['subject'] ?? 'Unknown Subject';
          final className = duty['class'] ?? 'Unknown Class';
          final date = duty['exam_date'] ?? 'No Date';

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.book_online, color: Colors.blueAccent),
              title: Text(
                subject,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "Class: $className\nExam Date: $date",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              trailing: CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
