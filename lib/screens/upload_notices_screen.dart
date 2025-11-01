import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadNoticesScreen extends StatefulWidget {
  const UploadNoticesScreen({super.key});

  @override
  State<UploadNoticesScreen> createState() => _UploadNoticesScreenState();
}

class _UploadNoticesScreenState extends State<UploadNoticesScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? selectedFile;
  Uint8List? webFile;
  String? fileName;
  bool isLoading = false;

  final String apiUrl = "http://10.3.1.3/exam_automation/upload_notice_pdf.php";

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );

    if (result != null) {
      if (kIsWeb) {
        webFile = result.files.single.bytes;
        fileName = result.files.single.name;
      } else {
        selectedFile = File(result.files.single.path!);
        fileName = selectedFile!.path.split('/').last;
      }
      setState(() {});
    }
  }

  Future<void> uploadNotice() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty || (selectedFile == null && webFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields and PDF file are required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['title'] = titleController.text;
      request.fields['description'] = descriptionController.text;

      if (kIsWeb && webFile != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'pdf',
          webFile!,
          filename: fileName,
        ));
      } else if (selectedFile != null) {
        request.files.add(await http.MultipartFile.fromPath('pdf', selectedFile!.path));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "Unknown response")),
      );

      if (data['success'] == true) {
        setState(() {
          titleController.clear();
          descriptionController.clear();
          selectedFile = null;
          webFile = null;
          fileName = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🌈 Elegant gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6E6FA), Color(0xFFD8BFD8), Color(0xFFB39DDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 14,
            shadowColor: Colors.deepPurple.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            color: Colors.white.withOpacity(0.95),
            child: Container(
              padding: const EdgeInsets.all(30),
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Upload Notice",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Title
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Notice Title",
                        labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Notice Description",
                        labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pick PDF
                    ElevatedButton.icon(
                      onPressed: pickPDF,
                      icon: const Icon(Icons.attach_file, color: Colors.white),
                      label: Text(
                        fileName != null ? "Selected: $fileName" : "Pick PDF",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9575CD),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Upload button
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.deepPurple)
                        : ElevatedButton(
                      onPressed: uploadNotice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E57C2),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        "Upload Notice",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
