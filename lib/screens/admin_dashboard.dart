import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/excel_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? _fileName;
  bool _isLoading = false;
  String _message = '';

  Future<void> _pickAndUploadExcel() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        _fileName = result.files.single.name;

        await ExcelService.readAndStoreExcel(filePath);
        setState(() {
          _message = 'Excel file $_fileName uploaded successfully!';
        });
      } else {
        setState(() {
          _message = 'No file selected';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickAndUploadExcel,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Excel File'),
                  ),
                  const SizedBox(height: 20),
                  Text(_message),
                ],
              ),
      ),
    );
  }
}
