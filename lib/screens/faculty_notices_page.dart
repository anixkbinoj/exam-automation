import 'package:flutter/material.dart';

class FacultyNoticesPage extends StatelessWidget {
  final List<dynamic> notices;

  const FacultyNoticesPage({super.key, required this.notices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notices")),
      body: notices.isEmpty
          ? const Center(child: Text("No new notices."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Card(
            color: const Color(0xFFFFFBEB),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications_active, color: Color(0xFFF59E0B)),
              title: Text(notice['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(notice['description']),
              trailing: Text(notice['date'], style: const TextStyle(fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}
