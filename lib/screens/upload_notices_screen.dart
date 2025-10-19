import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadNoticesScreen extends StatelessWidget {
  const UploadNoticesScreen({super.key});

  Future<void> pickNoticeFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      final filePath = result.files.single.path;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected file: $filePath')),
      );
      // TODO: upload notice to server
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Notices")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text("Select Notice File"),
          onPressed: () => pickNoticeFile(context),
        ),
      ),
    );
  }
}
