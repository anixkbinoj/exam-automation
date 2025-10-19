import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

class UploadSeatingScreen extends StatelessWidget {
  const UploadSeatingScreen({super.key});

  Future<void> pickExcelFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );
    if (result != null) {
      final filePath = result.files.single.path;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected file: $filePath')),
      );
      // TODO: upload file to server or parse Excel
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Seating Excel")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text("Select Excel File"),
          onPressed: () => pickExcelFile(context),
        ),
      ),
    );
  }
}
