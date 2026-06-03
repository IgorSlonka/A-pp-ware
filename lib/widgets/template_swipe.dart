// This file defines the TemplateSwipe widget, representing True/False swipe quiz cards.
// It supports gesture recognition (horizontal drags), rotates and translates the card dynamically,
// blends backgrounds to green (True) or red (False) based on drag direction, and displays explanation sheets.
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../models/lesson_model.dart';

class TemplateSwipe extends StatefulWidget {
  final Lesson lesson;
  final Function(bool wasCorrect) onAnswerSubmitted;

  const TemplateSwipe({
    // Constructor instantiating the swiper template, receiving the Lesson data model and answer callbacks.
    super.key,
    required this.lesson,
    required this.onAnswerSubmitted,
  });

  @override
  State<TemplateSwipe> createState() => _TemplateSwipeState();
}

class _TemplateSwipeState extends State<TemplateSwipe> {
  double _dragDx = 0.0;
  bool? _userAnswer;
  bool _revealed = false;

  Color get _categoryColor {
    // Getter returning theme coloring associated with lesson category groupings.
    switch (widget.lesson.category.toLowerCase()) {
      case 'topic1':
        return const Color(0xFFD946EF);
      case 'topic2':
        return const Color(0xFF06B6D4);
      case 'topic3':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFD946EF);
    }
  }

  void _submitAnswer(bool answer) {
    // Records the user's swiped answer option, triggers completion events, and locks state reviews.
    if (_revealed) return;

    setState(() {
      _userAnswer = answer;
      _revealed = true;
    });

    final bool isCorrect = answer == widget.lesson.correctAnswer;
    widget.onAnswerSubmitted(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    // Renders the viewport containing swipe guides, gesture listeners, translation vectors, and result screens.
    final bool isCorrect = _userAnswer == widget.lesson.correctAnswer;

    // Calculate rotation and horizontal offset for drag effect
    final double cardOffset = _dragDx;
    final double cardRotation = _dragDx / 400.0; // Subtle tilt

    // Calculate blending color based on drag distance
    final double ratio = (cardOffset.abs() / 150.0).clamp(0.0, 1.0);
    Color cardColor = const Color(0xFF1A1A2E);
    if (cardOffset > 0) {
      // Blend to solid vibrant green (up to 90% opacity)
      cardColor = Color.lerp(
        const Color(0xFF1A1A2E),
        const Color(0xFF58CC02).withOpacity(0.90),
        ratio,
      )!;
    } else if (cardOffset < 0) {
      // Blend to solid vibrant red (up to 90% opacity)
      cardColor = Color.lerp(
        const Color(0xFF1A1A2E),
        const Color(0xFFEF4444).withOpacity(0.90),
        ratio,
      )!;
    }

    final categoryColor = _categoryColor;

    return Container(
      color: const Color(0xFF0F0F1A),
      padding: const EdgeInsets.only(left: 20.0, top: 32.0, bottom: 32.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 125.0), // Spacer for top HUD

          // Category Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: categoryColor.withOpacity(0.3)),
            ),
            child: Text(
              widget.lesson.category.toUpperCase().replaceAll('TOPIC', 'TOPIC '),
              style: TextStyle(
                color: categoryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            widget.lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            "Swipe Right for TRUE, Left for FALSE",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Draggable/Swipe Card Box
          Expanded(
            child: Center(
              child: _revealed
                  ? _buildResultView(isCorrect)
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // Draggable/Swipeable Card that translates/rotates
                        GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            setState(() {
                              _dragDx += details.delta.dx;
                            });
                          },
                          onHorizontalDragEnd: (details) {
                            // Threshold of 80px for swiping action
                            if (_dragDx > 80) {
                              _submitAnswer(true); // Swiped Right -> True
                            } else if (_dragDx < -80) {
                              _submitAnswer(false); // Swiped Left -> False
                            }
                            setState(() {
                              _dragDx = 0.0; // Reset offset
                            });
                          },
                          child: Transform.translate(
                            offset: Offset(cardOffset, 0),
                            child: Transform.rotate(
                              angle: cardRotation,
                              child: _buildDraggableCard(cardColor, ratio),
                            ),
                          ),
                        ),

                        // High-visibility Centered overlay plate that stays centered in viewport
                        if (_dragDx.abs() > 15)
                          IgnorePointer(
                            child: AnimatedOpacity(
                              opacity: ratio,
                              duration: Duration.zero,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _dragDx > 0 ? const Color(0xFF58CC02) : const Color(0xFFEF4444),
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_dragDx > 0 ? const Color(0xFF58CC02) : const Color(0xFFEF4444)).withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _dragDx > 0 ? "TRUE" : "FALSE",
                                  style: TextStyle(
                                    color: _dragDx > 0 ? const Color(0xFF58CC02) : const Color(0xFFEF4444),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 42.0),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(Color cardColor, double ratio) {
    // Builds the physical flashcard that the student drags, blending colors and scaling borders dynamically.
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cardColor, // Dynamically color-blended card background!
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08 + (ratio * 0.15)),
          width: 1.5 + (ratio * 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "❓",
              style: TextStyle(fontSize: 44),
            ),
            const SizedBox(height: 20),
            MarkdownBody(
              data: widget.lesson.question ?? "",
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: WrapAlignment.center,
                strong: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                em: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
                code: TextStyle(
                  color: _categoryColor,
                  backgroundColor: _categoryColor.withOpacity(0.12),
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(bool isCorrect) {
    // Displays feedback widgets indicating if the user's swipe response was correct, alongside Markdown solutions.
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF58CC02).withOpacity(0.3)
              : Colors.redAccent.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_outline : Icons.error_outline,
            color: isCorrect ? const Color(0xFF58CC02) : Colors.redAccent,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            isCorrect ? "Correct!" : "Incorrect!",
            style: TextStyle(
              color: isCorrect ? const Color(0xFF58CC02) : Colors.redAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Your Answer: ${_userAnswer == true ? 'True' : 'False'}",
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: MarkdownBody(
                data: widget.lesson.explanation ?? "Explanation placeholder text.",
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.45,
                  ),
                  textAlign: WrapAlignment.center,
                  strong: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  em: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                  code: TextStyle(
                    color: _categoryColor,
                    backgroundColor: _categoryColor.withOpacity(0.12),
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
