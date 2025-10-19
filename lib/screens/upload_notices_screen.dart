import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadNoticesScreen extends StatefulWidget {
  const UploadNoticesScreen({super.key});

  @override
  State<UploadNoticesScreen> createState() => _UploadNoticesScreenState();
}

class _UploadNoticesScreenState extends State<UploadNoticesScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final String apiUrl = "http://10.3.2.145/exam_automation/upload_notice.php";

  Future<void> uploadNotice() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    final response = await http.post(Uri.parse(apiUrl), body: {
      'title': titleController.text,
      'description': descriptionController.text,
    });

    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data['message'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Notices")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Notice Title"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Notice Description"),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadNotice,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Upload Notice"),
            ),
          ],
        ),
      ),
    );
  }
}
