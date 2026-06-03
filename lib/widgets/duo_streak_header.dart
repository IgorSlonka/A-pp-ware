/// This file defines the DuoStreakHeader widget, representing the top gamified dashboard banner.
/// It displays the current daily streak (flame indicator), overall application title,
/// navigation profile button, and a gradient progress bar tracking XP milestones.
import 'dart:math';
import 'package:flutter/material.dart';

class DuoStreakHeader extends StatelessWidget {
  final int streak;
  final int currentXp;
  final int xpGoal;
  final VoidCallback onProfilePressed;

  const DuoStreakHeader({
    /// Constructor instantiating a top dashboard stats display widget.
    super.key,
    required this.streak,
    required this.currentXp,
    required this.xpGoal,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    /// Computes layout dimensions to render progress tracks, flame icons, and branding titles.
    final double progress = min(1.0, currentXp / xpGoal);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF16162A), // Premium dark theme banner background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row with Streak, App Title, and Profile Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Streak Flame Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "🔥",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$streak Days",
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cohesive App Name
                  const Text(
                    "A(PP)ware",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  // Profile Navigation Button (Avatar)
                  GestureDetector(
                    onTap: onProfilePressed,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3B82F6),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF1E1E2F),
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF3B82F6),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Daily XP Goal header label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "DAILY XP GOAL PROGRESS",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "$currentXp / $xpGoal XP",
                    style: const TextStyle(
                      color: Color(0xFF88FF00),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Daily XP Progress Bar stretching at the very bottom edge of the banner
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Stack(
                children: [
                  // Background track
                  Container(
                    height: 5,
                    color: Colors.white.withOpacity(0.08),
                  ),
                  // Active progress bar
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF58CC02),
                            Color(0xFF88FF00),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
