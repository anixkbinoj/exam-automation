import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ViewNoticesScreen extends StatefulWidget {
  final List<dynamic>? notices; // optional parameter

  const ViewNoticesScreen({super.key, this.notices});

  @override
  State<ViewNoticesScreen> createState() => _ViewNoticesScreenState();
}

class _ViewNoticesScreenState extends State<ViewNoticesScreen> {
  List notices = [];
  bool isLoading = true;

  final String apiUrl = "http://10.3.2.145/exam_automation/get_notices.php";

  @override
  void initState() {
    super.initState();
    if (widget.notices != null && widget.notices!.isNotEmpty) {
      notices = widget.notices!;
      isLoading = false;
    } else {
      fetchNotices();
    }
  }

  Future<void> fetchNotices() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          notices = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load notices")),
        );
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
          .showSnackBar(const SnackBar(content: Text("Could not open PDF")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6E6FA), Color(0xFFD8BFD8), Color(0xFFB39DDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 💜 Header
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: const Text(
                  "📢 Notices",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6A1B9A),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 🌀 Body
              Expanded(
                child: isLoading
                    ? const Center(
                    child:
                    CircularProgressIndicator(color: Colors.deepPurple))
                    : notices.isEmpty
                    ? const Center(
                  child: Text(
                    "No notices available",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    return Card(
                      color: Colors.white.withOpacity(0.95),
                      elevation: 6,
                      shadowColor: Colors.deepPurple.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin:
                      const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf,
                            color: Colors.redAccent, size: 30),
                        title: Text(
                          notice['title'] ?? "Untitled Notice",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            if (notice['description'] != null &&
                                notice['description'].toString().isNotEmpty)
                              Padding(
                                padding:
                                const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  notice['description'],
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 5),
                            Text(
                              "Uploaded: ${notice['created_at'] ?? ''}",
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.deepPurple),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_rounded,
                              color: Color(0xFF7E57C2), size: 28),
                          onPressed: () =>
                              openPDF(notice['file_path']),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
