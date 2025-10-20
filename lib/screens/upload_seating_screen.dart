import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class UploadSeatingScreen extends StatefulWidget {
  const UploadSeatingScreen({super.key});

  @override
  State<UploadSeatingScreen> createState() => _UploadSeatingScreenState();
}

class _UploadSeatingScreenState extends State<UploadSeatingScreen> {
  String? selectedDepartment;
  String? selectedSemester;
  bool isUploading = false;
  String message = "";

  final List<String> departments = [
    "CSE",
    "ECE",
    "EEE",
    "MECH",
    "CIVIL",
    "AI&DS",
  ];

  final List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];

  // Your PHP endpoint
  final String uploadUrl =
      "http://10.159.50.69/exam_automation/upload_seating_excel.php";

  Future<void> uploadExcel() async {
    if (selectedDepartment == null || selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select department and semester")),
      );
      return;
    }

    // Pick Excel file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
      withData: true, // Needed for web
    );

    if (result == null) return; // Cancelled

    setState(() {
      isUploading = true;
      message = "Uploading...";
    });

    try {
      // Use bytes instead of path for web support
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = result.files.first.name;

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Attach form data
      request.fields['department'] = selectedDepartment!;
      request.fields['semester'] = selectedSemester!;

      // Attach file
      if (fileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // Must match PHP key
            fileBytes,
            filename: fileName,
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      // It's crucial to check if the widget is still mounted before updating the UI.
      if (!mounted) return;

      try {
        var data = jsonDecode(responseBody);

        if (response.statusCode == 200 && data['status'] == 'success') {
          setState(() {
            message = data['message'];
          });
        } else {
          setState(() {
            message =
                data['message'] ??
                "Upload failed with status ${response.statusCode}";
          });
        }
      } on FormatException catch (e) {
        // This block will catch the JSON parsing error.
        debugPrint(
          "Server returned invalid JSON. Response body:\n$responseBody",
        );
        setState(() {
          message =
              "Server returned an invalid response. Please check server logs.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        message = "Error: $e";
      });
    }

    // Display the final message in a SnackBar
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Seating Arrangement"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              items: departments
                  .map(
                    (dept) => DropdownMenuItem(value: dept, child: Text(dept)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedDepartment = val),
              decoration: const InputDecoration(
                labelText: "Select Department",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSemester,
              items: semesters
                  .map(
                    (sem) => DropdownMenuItem(
                      value: sem,
                      child: Text("Semester $sem"),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedSemester = val),
              decoration: const InputDecoration(
                labelText: "Select Semester",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isUploading ? null : uploadExcel,
              icon: const Icon(Icons.upload_file),
              label: Text(isUploading ? "Uploading..." : "Upload Excel"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 30),
            if (message.isNotEmpty)
              Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
