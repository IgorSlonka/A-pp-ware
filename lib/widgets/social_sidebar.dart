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
            side: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.5),
          ),
          title: Row(
            children: [
              const Text(
                "💡 ",
                style: TextStyle(fontSize: 22),
              ),
              Expanded(
                child: Text(
                  "${widget.topic} Explanation",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(
            widget.explanation ?? "Explanation placeholder text. Learn more daily!",
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

  @override
  Widget build(BuildContext context) {
    final showLearnOption = widget.explanation != null;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, bottom: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              cardColor: const Color(0xFF1E1E2F),
              popupMenuTheme: PopupMenuThemeData(
                color: const Color(0xFF1E1E2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                elevation: 8,
              ),
            ),
            child: PopupMenuButton<String>(
              offset: const Offset(0, -225), // Shorter y-offset to lift the menu upwards (opens above the button)
              icon: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.more_vert, // Vertical triple-dot menu
                  color: Colors.white,
                  size: 24,
                ),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'save':
                    _toggleBookmark();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isBookmarked ? "Removed from bookmarks" : "Saved to bookmarks!"),
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color(0xFF1E1E2F),
                      ),
                    );
                    break;
                  case 'learn':
                    _showExplanationDialog(context);
                    break;
                  case 'share':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Link copied to clipboard!"),
                        duration: Duration(seconds: 1),
                        backgroundColor: Color(0xFF1E1E2F),
                      ),
                    );
                    break;
                  case 'skip':
                    if (widget.onSkipSectionPressed != null) {
                      widget.onSkipSectionPressed!();
                    }
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'save',
                  child: Row(
                    children: [
                      Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? Colors.amber : Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isBookmarked ? "Saved" : "Save",
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'learn',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.greenAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Learn",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'share',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.share,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Share",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<String>(
                  value: 'skip',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fast_forward,
                        color: Colors.amberAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Skip",
                        style: TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
