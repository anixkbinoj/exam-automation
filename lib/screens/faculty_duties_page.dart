import 'package:flutter/material.dart';

class FacultyDutiesPage extends StatelessWidget {
  final List<dynamic> duties;

  const FacultyDutiesPage({super.key, required this.duties});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assigned Duties")),
      body: duties.isEmpty
          ? const Center(child: Text("No duties assigned."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: duties.length,
        itemBuilder: (context, index) {
          final duty = duties[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.assignment, color: Color(0xFF2563EB)),
              title: Text("${duty['class']} - ${duty['subject']}"),
              subtitle: Text("Exam Date: ${duty['exam_date']}"),
            ),
          );
        },
      ),
    );
  }
}
