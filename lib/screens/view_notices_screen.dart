import 'package:flutter/material.dart';

class ViewNoticesScreen extends StatelessWidget {
  const ViewNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(child: Text("Notices will be displayed here.")),
    );
  }
}
