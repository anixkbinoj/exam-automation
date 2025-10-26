import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

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
  bool _isLoading = false;

  Future<void> allotDuty() async {
    if (emailController.text.isEmpty ||
        classController.text.isEmpty ||
        subjectController.text.isEmpty ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.allotTeacher),
        body: {
          'email': emailController.text.trim(),
          'class': classController.text.trim(),
          'subject': subjectController.text.trim(),
          'exam_date': dateController.text.trim(),
        },
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'An unknown error occurred.'),
          backgroundColor: data['status'] == 'success'
              ? Colors.green
              : Colors.red,
        ),
      );

      if (data['status'] == 'success') {
        // Clear fields on success
        emailController.clear();
        classController.clear();
        subjectController.clear();
        dateController.clear();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Allot Teacher Duties"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildTextField(
                controller: emailController,
                labelText: "Teacher Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: classController,
                labelText: "Class",
                icon: Icons.class_,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: subjectController,
                labelText: "Subject",
                icon: Icons.book,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: dateController,
                labelText: "Exam Date (YYYY-MM-DD)",
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: allotDuty,
                      icon: const Icon(Icons.assignment_turned_in),
                      label: const Text("Allot Duty"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.deepPurple.shade300),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
