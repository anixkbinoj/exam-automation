import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllotTeacherScreen extends StatefulWidget {
  const AllotTeacherScreen({super.key});

  @override
  State<AllotTeacherScreen> createState() => _AllotTeacherScreenState();
}

class _AllotTeacherScreenState extends State<AllotTeacherScreen> {
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _examHallController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Allot Teacher Duties")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _teacherController,
              decoration: const InputDecoration(
                labelText: "Teacher Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _examHallController,
              decoration: const InputDecoration(
                labelText: "Exam Hall",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final teacher = _teacherController.text;
                final hall = _examHallController.text;
                if (teacher.isNotEmpty && hall.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Assigned $teacher to $hall')),
                  );
                  _teacherController.clear();
                  _examHallController.clear();
                }
              },
              child: const Text("Assign Duty"),
            ),
          ],
        ),
      ),
    );
  }
}
