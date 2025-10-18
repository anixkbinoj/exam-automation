import 'package:flutter/material.dart';
import '../services/excel_service.dart';
import '../models/student.dart';

class StudentDashboard extends StatefulWidget {
  final String registerNumber;
  const StudentDashboard({super.key, required this.registerNumber});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Student? student;

  @override
  void initState() {
    super.initState();
    student = ExcelService.findStudent(widget.registerNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: Center(
        child: student == null || student!.registerNumber.isEmpty
            ? const Text('Record not found. Please check your number.')
            : Card(
                margin: const EdgeInsets.all(20),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Name: ${student!.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Class: ${student!.className}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Room: ${student!.roomNumber}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
