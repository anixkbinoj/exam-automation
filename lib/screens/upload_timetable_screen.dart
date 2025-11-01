import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart'; // Assuming you'll add the endpoint here

class UploadTimeTableScreen extends StatefulWidget {
  const UploadTimeTableScreen({super.key});

  @override
  State<UploadTimeTableScreen> createState() => _UploadTimeTableScreenState();
}

class _UploadTimeTableScreenState extends State<UploadTimeTableScreen> {
  bool _isUploading = false;
  String? _fileName;
  Uint8List? _fileBytes;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xls', 'xlsx', 'doc', 'docx'],
      withData: true, // Important for web and mobile to get bytes
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileBytes = result.files.single.bytes;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          ApiConfig.getTimetable,
        ), // Assuming this is the upload endpoint
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'timetable', // API key for the file
          _fileBytes!,
          filename: _fileName,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Upload status unknown')),
      );

      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() {
          _fileName = null;
          _fileBytes = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Exam Time Table"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_fileName ?? "Select Time Table File"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 50),
                ),
              ),
              const SizedBox(height: 20),
              if (_fileName != null)
                _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _uploadFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Upload File"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(250, 50),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
