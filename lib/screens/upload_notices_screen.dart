import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

class UploadNoticesScreen extends StatefulWidget {
  const UploadNoticesScreen({super.key});

  @override
  State<UploadNoticesScreen> createState() => _UploadNoticesScreenState();
}

class _UploadNoticesScreenState extends State<UploadNoticesScreen> {
  final TextEditingController titleController = TextEditingController();
  File? selectedFile;

  final String apiUrl = "http://10.3.2.145/exam_automation/upload_notice_pdf.php";

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadNotice() async {
    if (titleController.text.isEmpty || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Title and PDF file are required")));
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['title'] = titleController.text;
    request.files.add(await http.MultipartFile.fromPath('pdf', selectedFile!.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var data = jsonDecode(responseBody);

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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickPDF,
              icon: const Icon(Icons.attach_file),
              label: Text(selectedFile != null
                  ? "Selected: ${selectedFile!.path.split('/').last}"
                  : "Pick PDF"),
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
