import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ExamTimeTableScreen extends StatefulWidget {
  const ExamTimeTableScreen({super.key});

  @override
  State<ExamTimeTableScreen> createState() => _ExamTimeTableScreenState();
}

class _ExamTimeTableScreenState extends State<ExamTimeTableScreen> {
  List<dynamic> timetables = [];
  bool isLoading = true;

  final String apiUrl = "http://10.3.2.145/exam_automation/get_timetable.php";

  @override
  void initState() {
    super.initState();
    fetchTimeTable();
  }

  Future<void> fetchTimeTable() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          timetables = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load timetable");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> openPDF(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Unable to open file")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exam Time Table")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : timetables.isEmpty
          ? const Center(child: Text("No timetable available"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: timetables.length,
        itemBuilder: (context, index) {
          final item = timetables[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                item['subject'] ?? 'Unknown Subject',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                  "Date: ${item['exam_date']}\nSession: ${item['session']}"),
              trailing: item['file_path'] != null &&
                  item['file_path'].toString().isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.picture_as_pdf,
                    color: Colors.red),
                onPressed: () => openPDF(item['file_path']),
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
