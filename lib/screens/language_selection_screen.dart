/// This file defines the LanguageSelectionScreen widget, which serves as the app's entry screen.
/// It features smooth breathing neon/glow circles, glassmorphic UI panels,
/// and supports language selection (English vs. Polish) with a custom route transition.
import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';
import 'feed_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({
    /// Default constructor for LanguageSelectionScreen.
    super.key,
  });

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    /// Initializes the animation controllers for background breathing glows and content fade-ins.
    super.initState();
    
    // Smooth breathing glow animation for the backdrop neon circles
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Initial content fade-in entrance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    /// Standard cleanup of animations to prevent memory leaks.
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectLanguage(String langCode) {
    /// Saves the language code selection and navigates to the FeedScreen with a custom fade transition.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FeedScreen(languageCode: langCode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Renders the glowing neon gradient circles and glassmorphic menu selection panel.
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Neon-Mesh Gradient Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0F0F1A),
            ),
          ),
          
          // Floating Animated Fuchsia Glow Circle
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Positioned(
                top: -50 + (_glowController.value * 60),
                right: -100 + (_glowController.value * 80),
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF007F).withOpacity(0.35),
                        const Color(0xFFFF007F).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Floating Animated Cyan Glow Circle
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Positioned(
                bottom: 50 - (_glowController.value * 80),
                left: -150 + (_glowController.value * 70),
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00F2FE).withOpacity(0.3),
                        const Color(0xFF00F2FE).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Floating Animated Green Glow Circle
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Positioned(
                top: 300 - (_glowController.value * 40),
                left: 100 + (_glowController.value * 50),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF58CC02).withOpacity(0.2),
                        const Color(0xFF58CC02).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Core Glassmorphic Selection Interface
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Stylized Brand / Icon representation
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.language_rounded,
                              size: 40,
                              color: Color(0xFF00F2FE),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // English Header
                          const Text(
                            "Choose Your Language",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          
                          // Polish Header
                          Text(
                            "Wybierz język aplikacji",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Language Option - English
                          _buildLanguageButton(
                            label: "English",
                            subtitle: "Learn in English",
                            flag: "🇬🇧",
                            color: const Color(0xFF00F2FE),
                            onTap: () => _selectLanguage('en'),
                          ),
                          const SizedBox(height: 16),

                          // Language Option - Polish
                          _buildLanguageButton(
                            label: "Polski",
                            subtitle: "Ucz się po polsku",
                            flag: "🇵🇱",
                            color: const Color(0xFFFF007F),
                            onTap: () => _selectLanguage('pl'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    /// Builds custom glassmorphic selector buttons containing language metadata and localized flag representations.
    required String label,
    required String subtitle,
    required String flag,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Country Flag Representation
              Text(
                flag,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              
              // Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action indicator Arrow
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
