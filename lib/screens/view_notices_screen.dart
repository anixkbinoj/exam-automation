import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';

class ViewNoticesScreen extends StatefulWidget {
  final List<dynamic>? notices; // optional parameter

  const ViewNoticesScreen({super.key, this.notices});

  @override
  State<ViewNoticesScreen> createState() => _ViewNoticesScreenState();
}

class _ViewNoticesScreenState extends State<ViewNoticesScreen> {
  List notices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // If notices already passed from dashboard, use them directly
    if (widget.notices != null && widget.notices!.isNotEmpty) {
      notices = widget.notices!;
      isLoading = false;
    } else {
      fetchNotices();
    }
  }

  Future<void> fetchNotices() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.getNotices));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          notices = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to load notices")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> openPDF(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open PDF")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notices")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notices.isEmpty
          ? const Center(child: Text("No notices available"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                    ),
                    title: Text(notice['title']),
                    subtitle: Text(notice['uploaded_at'] ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => openPDF(notice['file_path']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
