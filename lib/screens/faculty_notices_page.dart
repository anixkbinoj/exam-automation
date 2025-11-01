import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FacultyNoticesPage extends StatelessWidget {
  final List<dynamic> notices;

  const FacultyNoticesPage({super.key, required this.notices});

  /// 🔹 Open PDF or external file link
  Future<void> _openFile(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("⚠️ Could not open file: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: notices.isEmpty
          ? const Center(
        child: Text(
          "No new notices.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          final title = notice['title'] ?? 'Untitled';
          final description = notice['description'] ?? 'No description available.';
          final date = notice['date'] ?? '';
          final filePath = notice['file_path'] ?? '';

          return Card(
            color: const Color(0xFFFFFBEB),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.campaign, color: Colors.orange),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(description),
                    trailing: Text(
                      date,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (filePath.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _openFile(filePath),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("View / Download"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
