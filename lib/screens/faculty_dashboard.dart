import 'package:flutter/material.dart';
import 'login_screen.dart';

class FacultyDashboard extends StatelessWidget {
  final String facultyId;

  const FacultyDashboard({super.key, required this.facultyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(child: Text("Welcome, Faculty ID: $facultyId")),
    );
  }
}
