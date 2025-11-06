import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // Use .asset for both mobile and web for reliable asset loading.
    try {
      _controller = VideoPlayerController.asset('assets/videos/splash.mp4');
      await _controller.initialize();
      _controller.setVolume(0); // Mute to allow autoplay on Chrome
      _controller.play();

      if (!mounted) return;
      setState(() {}); // rebuild after initialize

      // Navigate when video ends
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration &&
            !_navigated) {
          _navigateToLogin();
        }
      });
    } catch (e) {
      // If video fails to load, log the error and navigate to login screen
      // as a fallback. This prevents the user from being stuck.
      debugPrint("Error initializing video player: $e");
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            // Show a black container matching the video's start to avoid a jarring
            // loading indicator. This makes the transition feel seamless.
            : Container(color: Colors.black),
      ),
    );
  }
}
