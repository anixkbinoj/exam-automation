import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllotTeacherScreen extends StatefulWidget {
  const AllotTeacherScreen({super.key});

  @override
  State<AllotTeacherScreen> createState() => _AllotTeacherScreenState();
}

class _AllotTeacherScreenState extends State<AllotTeacherScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final String apiUrl = "http://10.36.154.208/exam_automation/allot_teacher.php";

  Future<void> allotDuty() async {
    if (emailController.text.isEmpty ||
        classController.text.isEmpty ||
        subjectController.text.isEmpty ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    final response = await http.post(Uri.parse(apiUrl), body: {
      'email': emailController.text,
      'class': classController.text,
      'subject': subjectController.text,
      'exam_date': dateController.text,
    });

    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data['message'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Allot Teacher Duties")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: classController,
              decoration: const InputDecoration(labelText: "Class"),
            ),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: "Subject"),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Exam Date (YYYY-MM-DD)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: allotDuty,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Allot Duty"),
            ),
          ],
        ),
      ),
    );
  }
}
