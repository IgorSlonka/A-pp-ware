import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../models/lesson_model.dart';

class TemplateMcq extends StatefulWidget {
  final Lesson lesson;
  final Function(bool wasCorrect) onAnswerSubmitted;

  const TemplateMcq({
    super.key,
    required this.lesson,
    required this.onAnswerSubmitted,
  });

  @override
  State<TemplateMcq> createState() => _TemplateMcqState();
}

class _TemplateMcqState extends State<TemplateMcq> {
  int? _selectedOptionIndex;
  bool _revealed = false;

  Color get _categoryColor {
    switch (widget.lesson.category.toLowerCase()) {
      case 'topic1':
        return const Color(0xFFD946EF);
      case 'topic2':
        return const Color(0xFF06B6D4);
      case 'topic3':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF14B8A6);
    }
  }

  void _submitAnswer(int index) {
    if (_revealed) return;

    setState(() {
      _selectedOptionIndex = index;
      _revealed = true;
    });

    final bool isCorrect = index == widget.lesson.correctOptionIndex;
    widget.onAnswerSubmitted(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.lesson.options ?? [];

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
          const SizedBox(height: 18),

          // Question container box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 68.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1.5,
              ),
            ),
            child: MarkdownBody(
              data: widget.lesson.question ?? "",
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
                strong: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                em: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
                code: TextStyle(
                  color: categoryColor,
                  backgroundColor: categoryColor.withOpacity(0.12),
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Option list buttons
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final optionText = options[index];
                return _buildOptionButton(index, optionText);
              },
            ),
          ),

          // Explanation reveal box
          if (_revealed) ...[
            const SizedBox(height: 16),
            _buildExplanationBox(),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index, String optionText) {
    Color borderColor = Colors.white.withOpacity(0.1);
    Color fillColor = const Color(0xFF1E1E2F);
    Widget? trailingIcon;

    if (_revealed) {
      final bool isCorrect = index == widget.lesson.correctOptionIndex;
      final bool isSelected = index == _selectedOptionIndex;

      if (isCorrect) {
        // Correct answer always glows green
        borderColor = const Color(0xFF58CC02);
        fillColor = const Color(0xFF58CC02).withOpacity(0.12);
        trailingIcon = const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 20);
      } else if (isSelected) {
        // Selected incorrect choice glows red
        borderColor = Colors.redAccent;
        fillColor = Colors.redAccent.withOpacity(0.12);
        trailingIcon = const Icon(Icons.cancel, color: Colors.redAccent, size: 20);
      } else {
        // Unselected incorrect choice fades out
        fillColor = const Color(0xFF151525);
        borderColor = Colors.white.withOpacity(0.04);
      }
    }

    return GestureDetector(
      onTap: () => _submitAnswer(index),
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 68.0),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  color: _revealed && index != widget.lesson.correctOptionIndex && index != _selectedOptionIndex
                      ? Colors.white30
                      : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationBox() {
    final bool wasCorrect = _selectedOptionIndex == widget.lesson.correctOptionIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: wasCorrect ? const Color(0xFF58CC02).withOpacity(0.08) : Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: wasCorrect ? const Color(0xFF58CC02).withOpacity(0.3) : Colors.redAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                wasCorrect ? "✅ Correct!" : "❌ Incorrect!",
                style: TextStyle(
                  color: wasCorrect ? const Color(0xFF58CC02) : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          MarkdownBody(
            data: widget.lesson.explanation ?? "",
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
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
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
