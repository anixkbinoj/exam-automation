import 'package:flutter/material.dart';

class ExamTimeTableScreen extends StatelessWidget {
  const ExamTimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Time Table"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(child: Text("Exam timetable will be displayed here.")),
    );
  }
}
