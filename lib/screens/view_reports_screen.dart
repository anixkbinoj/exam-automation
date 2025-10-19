import 'package:flutter/material.dart';

class ViewReportsScreen extends StatelessWidget {
  const ViewReportsScreen({super.key});

  final List<Map<String, dynamic>> sampleData = const [
    {"name": "Alice", "register": "R001", "points": 90},
    {"name": "Bob", "register": "R002", "points": 85},
    {"name": "Charlie", "register": "R003", "points": 95},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Reports")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Register Number")),
            DataColumn(label: Text("Points")),
          ],
          rows: sampleData
              .map(
                (data) => DataRow(
              cells: [
                DataCell(Text(data["name"])),
                DataCell(Text(data["register"])),
                DataCell(Text(data["points"].toString())),
              ],
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
