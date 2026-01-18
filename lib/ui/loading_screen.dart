import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Remove native splash when first frame is ready
    FlutterNativeSplash.remove();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    // Navigate to MeterScreen after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MeterScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo (Pulsing)
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/icon/icon.png',
                width: 180,
                height: 180,
              ),
            ),
            const SizedBox(height: 48),
            // App Name with subtle fade
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    'SWARAM',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w200,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'BY G9 INC.',
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: StitchColors.g9Blue,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: StitchColors.g9Blue,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
