import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/stitch_theme.dart';
import '../screens/meter_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigate to MeterScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MeterScreen()),
        );
      }
    });
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // G9 Logo Image
              Image.asset(
                'assets/icon/icon.png',
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 48),
              // App Name
              Text(
                'SWARAM',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'BY G9 INC.',
                style: GoogleFonts.raleway(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: StitchColors.g9Blue,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 64),
              // Loading Indicator
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: StitchColors.g9Blue,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
