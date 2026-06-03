/// This file defines the SocialSidebar widget, which houses TikTok-like floating action buttons.
/// It includes controls to Save (bookmark), Learn (read chapter explanation dialogs),
/// Share (copy link), and Skip (transition to next lesson segment) in a floating glassmorphic stack.
import 'package:flutter/material.dart';
import '../services/translations.dart';

class SocialSidebar extends StatefulWidget {
  final String topic;
  final String? explanation;
  final VoidCallback? onSkipSectionPressed;
  final bool isBookmarked;
  final Function(bool isBookmarked) onBookmarkChanged;
  final String languageCode;

  const SocialSidebar({
    /// Constructor defining essential action callbacks and chapter explanation text nodes.
    super.key,
    required this.topic,
    this.explanation,
    this.onSkipSectionPressed,
    required this.isBookmarked,
    required this.onBookmarkChanged,
    required this.languageCode,
  });

  @override
  State<SocialSidebar> createState() => _SocialSidebarState();
}

class _SocialSidebarState extends State<SocialSidebar> {
  void _toggleBookmark() {
    /// Toggles the bookmark state (Saved status flag) and updates the sidebar state.
    widget.onBookmarkChanged(!widget.isBookmarked);
  }

  void _showExplanationDialog(BuildContext context) {
    /// Renders a stylized glassmorphic modal dialogue containing helpful details and guidelines for the current chapter.
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

  bool _isMenuOpen = false;

  Widget _buildAnimatedOption({
    /// Widget builder for animated Expandable Floating Action Button menu 
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    Color textColor = Colors.white70,
  }) {
    final double targetBottom = _isMenuOpen ? (index + 1) * 72.0 : 0.0;
    final double targetOpacity = _isMenuOpen ? 1.0 : 0.0;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 300 + (index * 60)),
      curve: Curves.easeOutCubic,
      bottom: targetBottom,
      right: 0,
      left: 0,
      child: IgnorePointer(
        ignoring: !_isMenuOpen,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: targetOpacity,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isMenuOpen = false;
              });
              onTap();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E1E2F),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 2),
                
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    /// Builds the primary vertical expansion button controlling speed dial visibility and toggle rotations.
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMenuOpen = !_isMenuOpen;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isMenuOpen ? const Color(0xFF1E1E2F) : Colors.black.withOpacity(0.4),
          border: Border.all(
            color: _isMenuOpen ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.15),
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
        child: AnimatedRotation(
          turns: _isMenuOpen ? 0.25 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _isMenuOpen ? Icons.close : Icons.more_vert,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Renders the column stack positioning the floating action speed-dials relative to the screen layout.
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, bottom: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 44,
            height: _isMenuOpen ? 360.0 : 44.0,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                // Option 3: Skip (Topmost)
                _buildAnimatedOption(
                  index: 3,
                  icon: Icons.fast_forward,
                  iconColor: Colors.amberAccent,
                  textColor: Colors.amberAccent,
                  label: "Skip",
                  onTap: () {
                    if (widget.onSkipSectionPressed != null) {
                      widget.onSkipSectionPressed!();
                    }
                  },
                ),
                // Option 2: Share
                _buildAnimatedOption(
                  index: 2,
                  icon: Icons.share,
                  label: "Share",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppTranslations.translate(widget.languageCode, 'link_copied'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color(0xFF1E1E2F),
                      ),
                    );
                  },
                ),
                // Option 1: Learn
                _buildAnimatedOption(
                  index: 1,
                  icon: Icons.lightbulb_outline,
                  iconColor: Colors.greenAccent,
                  label: "Learn",
                  onTap: () => _showExplanationDialog(context),
                ),
                // Option 0: Save (Bottommost)
                _buildAnimatedOption(
                  index: 0,
                  icon: widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  iconColor: widget.isBookmarked ? Colors.amber : Colors.white,
                  label: widget.isBookmarked ? "Saved" : "Save",
                  onTap: () {
                    final targetSavedState = !widget.isBookmarked;
                    _toggleBookmark();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          targetSavedState
                              ? AppTranslations.translate(widget.languageCode, 'bookmark_added')
                              : AppTranslations.translate(widget.languageCode, 'bookmark_removed'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color(0xFF1E1E2F),
                      ),
                    );
                  },
                ),
                // Main toggle button floats at bottom: 0
                Positioned(
                  bottom: 0,
                  child: _buildToggleButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
