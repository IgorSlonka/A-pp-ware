import 'package:flutter/material.dart';
import 'dart:ui';
import 'screens/language_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EduTikTokApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class EduTikTokApp extends StatelessWidget {
  const EduTikTokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APPware',
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6), // blueAccent
          secondary: Color(0xFF58CC02), // Duolingo Green
          background: Color(0xFF0F0F1A),
          surface: Color(0xFF1E1E2F),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto', color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Roboto', color: Colors.white70),
        ),
        useMaterial3: true,
      ),
      home: const SmartphonePreviewWrapper(child: LanguageSelectionScreen()),
    );
  }
}

/// A responsive wrapper that frames the application in standard smartphone proportions
/// (430x932) with mock physical bezels and shadows when viewed on desktop browsers.
/// Automatically falls back to full-screen mode on physical mobile screens or small emulators.
class SmartphonePreviewWrapper extends StatelessWidget {
  final Widget child;

  const SmartphonePreviewWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the screen width is larger than a standard smartphone, wrap in a centered mockup frame
        if (constraints.maxWidth > 500) {
          return Scaffold(
            backgroundColor: const Color(0xFF07070F), // Deep outer space dark background
            body: Center(
              child: Container(
                width: 430, // standard width of modern large smartphones (e.g., iPhone 15 Pro Max)
                height: 932, // standard height of modern large smartphones
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A),
                  borderRadius: BorderRadius.circular(40), // Smartphone curved screens
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12), // Outer physical device bezel
                    width: 10.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30), // Match the inner bezel curves
                  child: child,
                ),
              ),
            ),
          );
        }

        // Otherwise on normal mobile display or small mobile views, fill the screen
        return child;
      },
    );
  }
}
