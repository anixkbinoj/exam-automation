import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isWeb ? 40 : 20,
          horizontal: isWeb ? 80 : 16,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B0082), Color(0xFFFFD700)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                title: 'App Highlights',
                content:
                    '• Exam Automation System\n• Seating Arrangement Display\n• Exam Timetable & Notices\n• Admin, Faculty, and Student Dashboards\n• Responsive UI for Web & Mobile',
              ),
              const SizedBox(height: 24),
              _buildCard(
                title: 'Developers',
                content: '• ANIX K BINOJ\n• ANN GRACE MATHEW',
              ),
              const SizedBox(height: 24),
              _buildCard(title: 'Origin', content: 'ANIX & CO'),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '© 2025 ANIX & CO',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: isWeb ? 18 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String content}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      shadowColor: Colors.deepPurpleAccent,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.deepPurple.shade900,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
