import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FacultyDutiesPage extends StatelessWidget {
  final List<dynamic> duties;

  const FacultyDutiesPage({super.key, required this.duties});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bgController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Assigned Duties"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: bgController,
        builder: (context, child) {
          final t = bgController.value;
          final colors = [
            Color.lerp(const Color(0xFF8E2DE2), const Color(0xFF4A00E0), t)!,
            Color.lerp(const Color(0xFF240046), const Color(0xFF5A189A), 1 - t)!,
            Color.lerp(const Color(0xFF3C096C), const Color(0xFF9D4EDD), t)!,
          ];

          return Stack(
            children: [
              // Animated gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Floating glowing particles
              ...List.generate(40, (index) {
                final rand = Random(index);
                final dx = rand.nextDouble() * size.width;
                final dy = (rand.nextDouble() * size.height +
                    (bgController.value * size.height)) %
                    size.height;
                final radius = rand.nextDouble() * 2 + 1;
                final opacity = 0.15 + rand.nextDouble() * 0.25;

                return Positioned(
                  left: dx,
                  top: dy,
                  child: Container(
                    width: radius,
                    height: radius,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),

              // Main Content
              duties.isEmpty
                  ? const Center(
                child: Text(
                  "No Assigned Duties Yet.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.only(top: 90, left: 16, right: 16),
                itemCount: duties.length,
                itemBuilder: (context, index) {
                  final duty = duties[index];

                  final subject = duty['subject'] ?? 'Unknown Subject';
                  final className = duty['class_name'] ??
                      duty['class'] ??
                      'Unknown Class';
                  final date =
                      duty['exam_date'] ?? duty['date'] ?? 'No Date';

                  return _glassDutyCard(subject, className, date, index);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _glassDutyCard(
      String subject, String className, String date, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Class: $className",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
          ),
          Text(
            "Exam Date: $date",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "#${index + 1}",
              style: GoogleFonts.poppins(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
