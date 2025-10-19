import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadTimeTableScreen extends StatelessWidget {
  const UploadTimeTableScreen({super.key});

  Future<void> pickTimeTableFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xls', 'xlsx', 'doc', 'docx'],
    );
    if (result != null) {
      final filePath = result.files.single.path;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selected file: $filePath')));
      // TODO: Implement file upload logic to the server
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Exam Time Table")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text("Select Time Table File"),
          onPressed: () => pickTimeTableFile(context),
        ),
      ),
    );
  }
}
