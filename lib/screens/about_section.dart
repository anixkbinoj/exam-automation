import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Function to launch a URL.
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // You could show a SnackBar here on failure
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: const Color(0xFF4B0082),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A0DAD), Color(0xFF9B30FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 80 : 16,
            vertical: isWeb ? 40 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'App Highlights',
                content:
                    '• Exam Automation System\n• Seating Arrangement Display\n• Exam Timetable & Notices\n• Admin, Faculty, and Student Dashboards\n• Responsive UI for Web & Mobile',
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Developers',
                content: '• ANIX K BINOJ\n• ANN GRACE MATHEW',
              ),
              const SizedBox(height: 24),
              _buildSectionCard(title: 'Origin', content: 'ANIX & CO'),
              const SizedBox(height: 36),

              // 🧩 Powered By Section
              Center(
                child: Column(
                  children: [
                    Text(
                      'Powered By',
                      style: GoogleFonts.poppins(
                        fontSize: isWeb ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logos Row (responsive)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        _buildLogo('assets/images/logo.png', 'ANIX & CO'),
                        _buildLogo('assets/images/antolans.png', 'ANTOLANZ'),
                        _buildLogo(
                          'assets/images/anonymous.png',
                          'TM ANONYMOUS',
                        ),
                        _buildLogo('assets/images/nullbyte.png', 'TM NULLBYTE'),
                        _buildLogo('assets/images/ai.png', 'Dept. of AI'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              Center(
                child: Text(
                  '© 2025 ANIX & CO | ANTOLANZ PVT. LTD',
                  style: GoogleFonts.poppins(
                    fontSize: isWeb ? 18 : 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => _launchURL(
                    'https://anixandco.gt.tc/',
                  ), // <-- TODO: Replace with your actual website URL
                  child: Text(
                    'Visit our Website',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.deepPurple.shade300,
      color: Colors.white.withOpacity(0.95),
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

  Widget _buildLogo(String path, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: Colors.white70, width: 1),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(path, fit: BoxFit.contain),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
