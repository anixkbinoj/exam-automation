import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class ViewFacultyScreen extends StatefulWidget {
  const ViewFacultyScreen({super.key});

  @override
  State<ViewFacultyScreen> createState() => _ViewFacultyScreenState();
}

class _ViewFacultyScreenState extends State<ViewFacultyScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> _facultyFuture;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..forward();
    _facultyFuture = _fetchFaculty();
  }

  Future<List<dynamic>> _fetchFaculty() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.viewFaculty));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['faculty'];
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching faculty: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '👩‍🏫 Faculty Members',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🌌 Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✨ Faculty List
          FutureBuilder<List<dynamic>>(
            future: _facultyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.purpleAccent,
                    strokeWidth: 3,
                  ),
                );
              } else if (snapshot.hasError) {
                return const Center(
                    child: Text(
                      "Error loading faculty data.",
                      style: TextStyle(color: Colors.white70),
                    ));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text(
                      "No faculty found.",
                      style: TextStyle(color: Colors.white70),
                    ));
              }

              final facultyList = snapshot.data!;
              return ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 90),
                itemCount: facultyList.length,
                itemBuilder: (context, index) {
                  final faculty = facultyList[index];
                  return FadeTransition(
                    opacity: _fadeController,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purpleAccent.withOpacity(0.2),
                            Colors.deepPurple.withOpacity(0.1)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border:
                        Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          faculty['name'] ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              "Department: ${faculty['department'] ?? '-'}",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Email: ${faculty['email'] ?? '-'}",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Phone: ${faculty['phone'] ?? '-'}",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
