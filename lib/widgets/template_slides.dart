import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../models/lesson_model.dart';

class TemplateSlides extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onSlidesCompleted;

  const TemplateSlides({
    super.key,
    required this.lesson,
    this.onSlidesCompleted,
  });

  @override
  State<TemplateSlides> createState() => _TemplateSlidesState();
}

class _TemplateSlidesState extends State<TemplateSlides> {
  final PageController _pageController = PageController();
  int _activePageIndex = 0;

  @override
  void initState() {
    super.initState();
    // If there is only one slide, it starts completed
    final slides = widget.lesson.slides ?? [];
    if (slides.length <= 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onSlidesCompleted != null) {
          widget.onSlidesCompleted!();
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white24, size: 48),
        ),
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white24, size: 48),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.lesson.slides ?? [];

    if (slides.isEmpty) {
      return const Center(
        child: Text(
          "No slides available for this lesson.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final Color categoryColor;
    switch (widget.lesson.category.toLowerCase()) {
      case 'topic1':
        categoryColor = const Color(0xFFD946EF);
        break;
      case 'topic2':
        categoryColor = const Color(0xFF06B6D4);
        break;
      case 'topic3':
        categoryColor = const Color(0xFF10B981);
        break;
      default:
        categoryColor = const Color(0xFF3B82F6);
    }

    return Container(
      color: const Color(0xFF0F0F1A), // Deep Slate dark mode
      padding: const EdgeInsets.only(left: 20.0, top: 32.0, bottom: 32.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Topic tag
          const SizedBox(height: 125.0), // Spacing for top HUD
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
          const SizedBox(height: 24),

          // Horizontal Swipeable Slide Deck wrapped in Stack with Chevrons
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _activePageIndex = index;
                    });
                    if (index == slides.length - 1 && widget.onSlidesCompleted != null) {
                      widget.onSlidesCompleted!();
                    }
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    final bool hasChart = slide.chartType.toLowerCase() != 'none' && slide.chartData.isNotEmpty;
                    final bool hasImage = slide.imagePath != null && slide.imagePath!.trim().isNotEmpty;
                    final bool showVisualSection = hasChart || hasImage;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Text section
                          Expanded(
                            flex: showVisualSection ? 3 : 1,
                            child: Container(
                              padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 68.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A2E), // Glassmorphic background
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.06),
                                  width: 1.5,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: MarkdownBody(
                                  data: slide.text,
                                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                                    p: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      height: 1.5,
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
                            ),
                          ),
                          if (showVisualSection) ...[
                            const SizedBox(height: 24),
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 68.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E2F).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.05),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasImage
                                          ? "VISUAL ILLUSTRATION"
                                          : "Visual Representation (${slide.chartType.toUpperCase()} CHART)",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Center(
                                        child: hasImage
                                            ? _buildImageWidget(slide.imagePath!)
                                            : Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                child: CustomPaint(
                                                  size: Size.infinite,
                                                  painter: EducationalChartPainter(
                                                    chartType: slide.chartType,
                                                    data: slide.chartData,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                // Left chevron button overlay
                if (_activePageIndex > 0)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 24),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // Right chevron button overlay
                if (_activePageIndex < slides.length - 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 24),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Progress Indicator Bar (Slide 1 of 3, etc.)
          // Centered slide dots and count indicator spanning the entire width underneath the card
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => Container(
                      width: index == _activePageIndex ? 20 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _activePageIndex
                            ? categoryColor
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Slide ${_activePageIndex + 1} of ${slides.length}",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Custom Canvas Painter that draws smooth lines, bar grids, and gradient fills
class EducationalChartPainter extends CustomPainter {
  final String chartType;
  final List<double> data;

  EducationalChartPainter({
    required this.chartType,
    required this.data,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paintGrid = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.0;

    // 1. Draw horizontal background grid lines
    final gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = size.height * (i / gridCount);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double minVal = 0.0;
    final double valRange = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    if (chartType.toLowerCase() == "bar") {
      // 2a. Draw Bar Chart
      final double spacing = size.width / (data.length * 2 + 1);
      final double barWidth = spacing;

      final paintBar = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF3B82F6), // vibrant blue
            Color(0xFF06B6D4), // cyan
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      for (int i = 0; i < data.length; i++) {
        final double ratio = data[i] / valRange;
        final double barHeight = size.height * ratio;
        final double x = spacing + i * (barWidth + spacing);
        final double y = size.height - barHeight;

        // Draw rounded rectangle bar
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        );
        canvas.drawRRect(rect, paintBar);
      }
    } else {
      // 2b. Draw Line Chart
      final double segmentWidth = size.width / (data.length - 1);
      final path = Path();
      final fillPath = Path();

      for (int i = 0; i < data.length; i++) {
        final double ratio = data[i] / valRange;
        final double x = i * segmentWidth;
        final double y = size.height - (size.height * ratio);

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, size.height);
          fillPath.lineTo(x, y);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }

        if (i == data.length - 1) {
          fillPath.lineTo(x, size.height);
          fillPath.close();
        }
      }

      // Draw area gradient fill
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueAccent.withOpacity(0.3),
            Colors.blueAccent.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      // Draw outer connection line
      final linePaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF6366F1), // violet
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);

      // Draw point markers
      final pointPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final outerPointPaint = Paint()
        ..color = const Color(0xFF3B82F6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      for (int i = 0; i < data.length; i++) {
        final double ratio = data[i] / valRange;
        final double x = i * segmentWidth;
        final double y = size.height - (size.height * ratio);

        canvas.drawCircle(Offset(x, y), 5.0, pointPaint);
        canvas.drawCircle(Offset(x, y), 5.0, outerPointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
