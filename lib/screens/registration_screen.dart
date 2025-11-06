import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  int step = 1;
  bool loading = false;
  bool showDebug = true; // ✅ toggle this to show/hide debug logs
  String debugLog = "";

  void logDebug(String message) {
    debugPrint("🔍 DEBUG: $message");
    if (mounted) {
      setState(() {
        debugLog += "\n$message";
      });
    }
  }

  Future<void> sendOTP() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your college email")),
      );
      return;
    }

    setState(() {
      loading = true;
      debugLog = "📤 Sending OTP request for $email...";
    });

    try {
      final url = Uri.parse(ApiConfig.verifyEmail);
      logDebug("Request URL: $url");

      final response = await http.post(url, body: {'email': email});

      logDebug("Response status: ${response.statusCode}");
      logDebug("Response body: ${response.body}");

      final data = jsonDecode(response.body);

      setState(() => loading = false);

      if (data['status'] == 'success') {
        logDebug("✅ OTP sent successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent to your college email")),
        );
        setState(() => step = 2);
      } else {
        logDebug("❌ OTP send failed: ${data['message']}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Error')));
      }
    } catch (e, st) {
      logDebug("❗ Exception: $e\n$st");
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> verifyOTP() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter OTP")));
      return;
    }

    setState(() {
      loading = true;
      debugLog = "📤 Verifying OTP for $email...";
    });

    try {
      final url = Uri.parse(ApiConfig.verifyOTP);
      logDebug("Request URL: $url");

      final response = await http.post(url, body: {'email': email, 'otp': otp});

      logDebug("Response status: ${response.statusCode}");
      logDebug("Response body: ${response.body}");

      final data = jsonDecode(response.body);

      setState(() => loading = false);

      if (data['status'] == 'success') {
        logDebug("✅ OTP verified successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP verified successfully")),
        );
        setState(() => step = 3);
      } else {
        logDebug("❌ OTP verification failed: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Invalid OTP')),
        );
      }
    } catch (e, st) {
      logDebug("❗ Exception: $e\n$st");
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    final newPass = newPassController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all password fields")),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() {
      loading = true;
      debugLog = "📤 Sending password reset for $email...";
    });

    try {
      final url = Uri.parse(ApiConfig.resetPassword);
      logDebug("Request URL: $url");

      final response = await http.post(
        url,
        body: {'email': email, 'new_password': newPass},
      );

      logDebug("Response status: ${response.statusCode}");
      logDebug("Response body: ${response.body}");

      final data = jsonDecode(response.body);

      setState(() => loading = false);

      if (data['status'] == 'success') {
        logDebug("✅ Password updated successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        logDebug("❌ Password update failed: ${data['message']}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Error')));
      }
    } catch (e, st) {
      logDebug("❗ Exception: $e\n$st");
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildCurrentStep() {
    switch (step) {
      case 1:
        return Column(
          key: const ValueKey(1),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your college email",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "College Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : sendOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B0082),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Send OTP"),
            ),
          ],
        );

      case 2:
        return Column(
          key: const ValueKey(2),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter OTP received via email",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B0082),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify OTP"),
            ),
          ],
        );

      case 3:
        return Column(
          key: const ValueKey(3),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Set a new password",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B0082),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update Password"),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Activation (Debug Mode)"),
        backgroundColor: const Color(0xFF4B0082),
        actions: [
          IconButton(
            icon: Icon(
              showDebug ? Icons.bug_report : Icons.bug_report_outlined,
            ),
            onPressed: () => setState(() => showDebug = !showDebug),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showDebug)
            Container(
              color: Colors.black87,
              height: 180,
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Text(
                  debugLog,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
