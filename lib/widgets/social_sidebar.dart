import 'package:flutter/material.dart';

class SocialSidebar extends StatefulWidget {
  final String topic;
  final String? explanation;
  final VoidCallback? onSkipSectionPressed;

  const SocialSidebar({
    super.key,
    required this.topic,
    this.explanation,
    this.onSkipSectionPressed,
  });

  @override
  State<SocialSidebar> createState() => _SocialSidebarState();
}

class _SocialSidebarState extends State<SocialSidebar> {
  bool _isBookmarked = false;

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  void _showExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderBorderSide(),
          ),
          title: Row(
            children: [
              const Text(
                "💡 ",
                style: TextStyle(fontSize: 22),
              ),
              Text(
                "${widget.topic} Explanation",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            widget.explanation ?? "Lorem ipsum explanation placeholder. Learn more daily!",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                "Got it!",
                style: TextStyle(
                  color: Color(0xFF58CC02),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  BorderSide BorderBorderSide() {
    return BorderSide(color: Colors.white.withOpacity(0.12), width: 1.5);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0, bottom: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Bookmark Button
          _buildSidebarButton(
            icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: _isBookmarked ? Colors.amber : Colors.white,
            label: _isBookmarked ? "Saved" : "Save",
            onTap: _toggleBookmark,
          ),
          const SizedBox(height: 18),

          // Explanation / Study Guide Info Button
          if (widget.explanation != null) ...[
            _buildSidebarButton(
              icon: Icons.lightbulb_outline,
              color: Colors.greenAccent,
              label: "Learn",
              onTap: () => _showExplanationDialog(context),
            ),
            const SizedBox(height: 18),
          ],

          // Share Button
          _buildSidebarButton(
            icon: Icons.share,
            color: Colors.white,
            label: "Share",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Link copied to clipboard!"),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF1E1E2F),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Skip Button
          _buildSidebarButton(
            icon: Icons.fast_forward,
            color: Colors.amberAccent,
            label: "Skip",
            onTap: () {
              if (widget.onSkipSectionPressed != null) {
                widget.onSkipSectionPressed!();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: 0.35, // Premium subtle transparency overlay to blend naturally with card backgrounds
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.2), // highly transparent dark background
                border: Border.all(
                  color: Colors.white.withOpacity(0.06), // micro-thin faint border
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60, // slightly more transparent text labels
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
