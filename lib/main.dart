import 'package:flutter/material.dart';
import 'theme/stitch_theme.dart';
import 'ui/loading_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const SwaramApp());
}

class SwaramApp extends StatelessWidget {
  const SwaramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swaram',
      debugShowCheckedModeBanner: false,
      theme: StitchTheme.darkTheme,
      home: const LoadingScreen(),
    );
  }
}
