// This file defines the FeedScreen widget, representing the main application screen.
// It integrates a TikTok-like vertical swipe feed with gamification elements like streaks,
// XP goals, and accuracy stats. It supports multiple tabs (Feed, Explore, Search, Summary)
// and handles learning sessions populated dynamically from a local database of lessons.
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/feed_engine.dart';
import '../services/translations.dart';
import '../models/lesson_model.dart';
import '../widgets/duo_streak_header.dart';
import '../widgets/social_sidebar.dart';
import '../widgets/template_slides.dart';
import '../widgets/template_swipe.dart';
import '../widgets/template_mcq.dart';

class FeedScreen extends StatefulWidget {
  final String languageCode;

  const FeedScreen({
    // Constructor for the primary FeedScreen, passing the current localization language code.
    super.key,
    required this.languageCode,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedEngine _feedEngine = FeedEngine();
  final PageController _pageController = PageController();
  final List<Lesson> _sessionLessons = [];
  bool _isLoading = true;

  // Bottom Navigation Tab Index
  int _selectedTabIndex = 0;

  // Duolingo Gamification States
  int _streak = 5;
  int _currentXp = 45;
  final int _xpGoal = 100;

  // Active Session Metrics
  int _sessionTotalQuestions = 0;
  int _sessionCorrectQuestions = 0;

  // Interactive Trackers (Count only upon user engagement)
  final Set<String> _interactedLessonIds = {};
  int _cardsReviewed = 0;

  // Overall Quiz Performance (Overall Accuracy calculation)
  int _overallTotalQuizzes = 0;
  int _overallCorrectQuizzes = 0;

  // Topic & Type Completions for interactive stats charts
  final Map<String, int> _completedByTopic = {
    'topic1': 0,
    'topic2': 0,
    'topic3': 0,
  };
  final Map<String, int> _completedByType = {
    'slides': 0,
    'swipe': 0,
    'mcq': 0,
  };

  @override
  void initState() {
    // Initializes the screen state and triggers lazy loading of lesson resources.
    super.initState();
    _initFeedEngine();
  }

  @override
  void dispose() {
    // Cleans up controllers and hardware listeners to prevent memory leaks.
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initFeedEngine() async {
    // Connects to the local JSON database via FeedEngine to download relevant curriculum nodes.
    await _feedEngine.loadLessons(widget.languageCode);
    _generateNewSession();
    setState(() {
      _isLoading = false;
    });
  }

  /// Generates a new lesson segment group of random size 5 to 12.
  /// Resets active session quiz scores.
  void _generateNewSession() {
    // Generates a random set of 5 to 12 lessons for the current learning round and resets session scores.
    _sessionLessons.clear();
    _sessionTotalQuestions = 0;
    _sessionCorrectQuestions = 0;

    if (_feedEngine.lessons.isEmpty) return;

    final random = Random();
    final int size = 5 + random.nextInt(8); // Generates length 5 to 12

    for (int i = 0; i < size; i++) {
      _sessionLessons.add(_feedEngine.getNextLessonSpacedRepetition());
    }
  }

  /// Triggered when the user scrolls past the summary card
  void _loadNextSession() {
    // Resets session context and jumps the PageView index back to the beginning of the slide deck.
    setState(() {
      _generateNewSession();
    });
    _pageController.jumpToPage(0);
  }

  /// Instant skip callback (bypass summary, launch next section)
  void _handleSkipSection() {
    // Skip action that bypasses summary entirely, instantly loading a fresh deck of randomized cards.
    setState(() {
      _generateNewSession();
    });
    _pageController.jumpToPage(0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.translate(widget.languageCode, 'section_skipped')),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF1E1E2F),
      ),
    );
  }

  /// Called upon MCQ/Swipe quiz submission
  void _handleAnswerSubmitted(String lessonId, bool wasCorrect) {
    // Processes a submitted user answer (MCQ or Swipe), updates XP, pass states, and validates daily goals.
    _feedEngine.recordReview(lessonId, wasCorrect);

    // Fetch the lesson object to pull metadata
    final lesson = _feedEngine.lessons.firstWhere((l) => l.id == lessonId);
    final category = lesson.category;
    final typeStr = lesson.type == LessonType.mcq ? 'mcq' : 'swipe';

    // Increment overall statistics only if this is the first interaction with this lesson
    if (!_interactedLessonIds.contains(lessonId)) {
      setState(() {
        _interactedLessonIds.add(lessonId);
        _cardsReviewed++;
        _completedByTopic[category] = (_completedByTopic[category] ?? 0) + 1;
        _completedByType[typeStr] = (_completedByType[typeStr] ?? 0) + 1;
      });
    }

    // Always log to current session & overall counts
    setState(() {
      _sessionTotalQuestions++;
      _overallTotalQuizzes++;
      if (wasCorrect) {
        _sessionCorrectQuestions++;
        _overallCorrectQuizzes++;
        _currentXp += 15;

        // If daily goal is reached, extend streak
        if (_currentXp >= _xpGoal) {
          _streak++;
          _currentXp = _currentXp - _xpGoal;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.translate(widget.languageCode, 'streak_extended_goal') + "$_streak" + AppTranslations.translate(widget.languageCode, 'days')),
              backgroundColor: const Color(0xFF58CC02),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        _currentXp = (_currentXp - 5 < 0) ? 0 : _currentXp - 5;
      }
    });
  }

  /// Called when the user completes a slide deck
  void _handleSlideCompleted(String lessonId, String category) {
    // Processes slide review completions, awarding flat XP and updating completed counts.
    _feedEngine.recordReview(lessonId, true);

    if (!_interactedLessonIds.contains(lessonId)) {
      setState(() {
        _interactedLessonIds.add(lessonId);
        _cardsReviewed++;
        _completedByTopic[category] = (_completedByTopic[category] ?? 0) + 1;
        _completedByType['slides'] = (_completedByType['slides'] ?? 0) + 1;

        // Award flat XP for full slide review completion
        _currentXp += 15;
        if (_currentXp >= _xpGoal) {
          _streak++;
          _currentXp = _currentXp - _xpGoal;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.translate(widget.languageCode, 'streak_extended_slide') + "$_streak" + AppTranslations.translate(widget.languageCode, 'days')),
              backgroundColor: const Color(0xFF58CC02),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Standard Flutter build method establishing the global scaffold and floating navigation structures.
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          // 1. Tab View Body
          Positioned.fill(
            child: _buildActiveTabContent(),
          ),

          // 2. Cohesive Duolingo Top Banner (Persistent Overlay)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DuoStreakHeader(
              streak: _streak,
              currentXp: _currentXp,
              xpGoal: _xpGoal,
              onProfilePressed: () {
                setState(() {
                  _selectedTabIndex = 3; // Swapping to Summary tab acts as profile
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildActiveTabContent() {
    // Router utility returning the corresponding tab view content depending on selected bottom navigation index.
    switch (_selectedTabIndex) {
      case 0:
        return _buildMainFeedTab();
      case 1:
        return _buildExploreTab();
      case 2:
        return _buildSearchTab();
      case 3:
        return _buildSummaryTab();
      default:
        return _buildMainFeedTab();
    }
  }

  // --- TAB 0: MAIN TIKTOK FEED (Segmented Groups & Transitions) ---
  Widget _buildMainFeedTab() {
    // Constructs the vertical scrolling PageView representing the main TikTok-style microlearning feed.
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: _pageController,
      itemCount: _sessionLessons.length + 2, // Lessons + Summary Card + Transition trigger
      onPageChanged: (index) {
        if (index == _sessionLessons.length + 1) {
          _loadNextSession();
        }
      },
      itemBuilder: (context, index) {
        if (index < _sessionLessons.length) {
          final lesson = _sessionLessons[index];

          return Stack(
            children: [
              // Interactive Learning Card
              Positioned.fill(
                child: _buildCardTemplate(lesson),
              ),

              // Floating TikTok Social Sidebar on the right
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SocialSidebar(
                    topic: lesson.topic,
                    explanation: lesson.explanation,
                    onSkipSectionPressed: _handleSkipSection,
                  ),
                ),
              ),
            ],
          );
        } else if (index == _sessionLessons.length) {
          return _buildSectionSummaryCard();
        } else {
          // Transition / Loading screen
          return Container(
            color: const Color(0xFF0F0F1A),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            ),
          );
        }
      },
    );
  }

  /// Renders a beautiful completed overview card showing accuracy percentage
  Widget _buildSectionSummaryCard() {
    // Builds a card overlay summary upon completing a lesson deck, visualizing accuracy and performance scores.
    final double accuracy = _sessionTotalQuestions > 0
        ? (_sessionCorrectQuestions / _sessionTotalQuestions) * 100
        : 100.0;

    return Container(
      color: const Color(0xFF0F0F1A),
      padding: const EdgeInsets.only(left: 20.0, top: 125.0, bottom: 32.0, right: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glassmorphic Trophy Circle
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02).withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF58CC02).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFF58CC02),
              size: 72,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            AppTranslations.translate(widget.languageCode, 'section_completed'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppTranslations.translate(widget.languageCode, 'section_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 36),

          // Accuracy metrics plate
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      AppTranslations.translate(widget.languageCode, 'accuracy'),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${accuracy.round()}%",
                      style: const TextStyle(
                        color: Color(0xFF58CC02),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  width: 1.5,
                  color: Colors.white.withOpacity(0.08),
                ),
                Column(
                  children: [
                    Text(
                      AppTranslations.translate(widget.languageCode, 'completed'),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${_sessionLessons.length}",
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppTranslations.translate(widget.languageCode, 'completed_cards'),
                      style: const TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Scroll up prompt
          Column(
            children: [
              Icon(
                Icons.keyboard_double_arrow_down,
                color: Colors.white.withOpacity(0.25),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                AppTranslations.translate(widget.languageCode, 'scroll_prompt'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 1: EXPLORE CHANNELS ---
  Widget _buildExploreTab() {
    // Renders the list of curriculum channels, compiling difficulty tags and slideshow counts dynamically.
    // Extract unique categories dynamically from feed engine lessons
    final List<String> categories = _feedEngine.lessons
        .map((l) => l.category)
        .toSet()
        .toList();

    final List<Map<String, String>> topics = categories.map((cat) {
      final lessons = _feedEngine.lessons.where((l) => l.category == cat).toList();
      
      // Select appropriate emoji icon based on category name keyword
      String icon = '📚';
      final lowerCat = cat.toLowerCase();
      if (lowerCat.contains('inteligenc') || lowerCat.contains('podstawy') || lowerCat.contains('basics')) {
        icon = '🧠';
      } else if (lowerCat.contains('search') || lowerCat.contains('wyszukiw')) {
        icon = '🔍';
      } else if (lowerCat.contains('obraz') || lowerCat.contains('generow') || lowerCat.contains('image')) {
        icon = '🎨';
      } else if (lowerCat.contains('bezpiecz') || lowerCat.contains('chron') || lowerCat.contains('safety') || lowerCat.contains('secur')) {
        icon = '🔒';
      } else if (lowerCat.contains('topic1')) {
        icon = '💡';
      } else if (lowerCat.contains('topic2')) {
        icon = '⚙️';
      } else if (lowerCat.contains('topic3')) {
        icon = '⚡';
      }

      // Assign difficulty levels systematically
      String level = widget.languageCode == 'pl' ? 'Łatwy' : 'Easy';
      if (cat.length % 3 == 0) {
        level = widget.languageCode == 'pl' ? 'Średni' : 'Medium';
      } else if (cat.length % 3 == 1) {
        level = widget.languageCode == 'pl' ? 'Trudny' : 'Hard';
      }

      // Count slideshows vs interactive quizzes
      final int slideCount = lessons.where((l) => l.type == LessonType.slides).length;
      final int quizCount = lessons.where((l) => l.type != LessonType.slides).length;

      final descTemplate = AppTranslations.translate(widget.languageCode, 'learn_slides') +
          "$slideCount" +
          AppTranslations.translate(widget.languageCode, 'slides_label') +
          "$quizCount" +
          AppTranslations.translate(widget.languageCode, 'quizzes_label');

      return {
        'title': cat,
        'desc': descTemplate,
        'icon': icon,
        'level': level,
        'percent': '${lessons.length} ${AppTranslations.translate(widget.languageCode, 'completed_cards')}',
      };
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 130.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.translate(widget.languageCode, 'explore_channels'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppTranslations.translate(widget.languageCode, 'explore_subtitle'),
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Channels Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final item = topics[index];
              return Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['icon']!,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        item['desc']!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['level']!,
                            style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          item['percent']!,
                          style: const TextStyle(
                            color: Color(0xFF58CC02),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 2: SEARCH CHANNELS ---
  Widget _buildSearchTab() {
    // Renders a search input field and compiles a list of recommended chapters and trending tags.
    final List<String> trendingHashtags = [
      '#LoremIpsum',
      '#DolorSit',
      '#AmetConsectetur',
      '#Adipiscing',
      '#SedDoEiusmod',
      '#TemporLabore',
      '#UtEnimAdMinim',
      '#Topic1',
      '#Topic2',
      '#Topic3',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 130.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.translate(widget.languageCode, 'search_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Search Input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2F),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF3B82F6)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppTranslations.translate(widget.languageCode, 'search_hint'),
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Trending hashtags
          Text(
            AppTranslations.translate(widget.languageCode, 'trending_hashtags'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: trendingHashtags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Recommended Channels list
          Text(
            AppTranslations.translate(widget.languageCode, 'recommended'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.04),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F0F1A),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text("📚", style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.translate(widget.languageCode, 'recommended_chapter') + " ${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppTranslations.translate(widget.languageCode, 'recommended_desc'),
                            style: const TextStyle(color: Colors.white30, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 3: SUMMARY & STATS DASHBOARD (Completions & Interactive Progress Charts) ---
  Widget _buildSummaryTab() {
    // Builds the personal statistics and gamification dashboard showing overall student accuracy, categories completed, and progress meters.
    final int overallAccuracy = _overallTotalQuizzes > 0
        ? ((_overallCorrectQuizzes / _overallTotalQuizzes) * 100).round()
        : 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 130.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF3B82F6), width: 2),
                ),
                child: const CircleAvatar(
                  backgroundColor: Color(0xFF1E1E2F),
                  child: Icon(Icons.person, color: Color(0xFF3B82F6), size: 30),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.translate(widget.languageCode, 'learner_title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTranslations.translate(widget.languageCode, 'member_since'),
                    style: const TextStyle(color: Colors.white30, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dynamic Stats Row (Cards Reviewed & Quiz Accuracy)
          Text(
            AppTranslations.translate(widget.languageCode, 'performance_summary'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatBlock(
                  AppTranslations.translate(widget.languageCode, 'cards_reviewed'),
                  "$_cardsReviewed",
                  Icons.menu_book,
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatBlock(
                  AppTranslations.translate(widget.languageCode, 'quiz_accuracy'),
                  "$overallAccuracy%",
                  Icons.track_changes,
                  const Color(0xFF58CC02),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Topic-Based Completion Progress Bars
          Text(
            AppTranslations.translate(widget.languageCode, 'completions_topic'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatProgressRow(AppTranslations.translate(widget.languageCode, 'topic1'), _completedByTopic['topic1'] ?? 0, 10, const Color(0xFFD946EF)),
          const SizedBox(height: 12),
          _buildStatProgressRow(AppTranslations.translate(widget.languageCode, 'topic2'), _completedByTopic['topic2'] ?? 0, 10, const Color(0xFF06B6D4)),
          const SizedBox(height: 12),
          _buildStatProgressRow(AppTranslations.translate(widget.languageCode, 'topic3'), _completedByTopic['topic3'] ?? 0, 10, const Color(0xFF10B981)),
          
          const SizedBox(height: 24),

          // Question Type Completion Progress Bars
          Text(
            AppTranslations.translate(widget.languageCode, 'completions_type'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatProgressRow(AppTranslations.translate(widget.languageCode, 'slideshow'), _completedByType['slides'] ?? 0, 10, const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          _buildStatProgressRow(AppTranslations.translate(widget.languageCode, 'swipe'), _completedByType['swipe'] ?? 0, 10, const Color(0xFF58CC02)),
          const SizedBox(height: 12),
          _buildStatProgressRow(AppTranslations.translate(widget.languageCode, 'mcq'), _completedByType['mcq'] ?? 0, 10, Colors.amberAccent),

          const SizedBox(height: 32),

          // Reset Statistics Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _streak = 5;
                  _currentXp = 45;
                  _cardsReviewed = 0;
                  _interactedLessonIds.clear();
                  _completedByTopic.updateAll((key, val) => 0);
                  _completedByType.updateAll((key, val) => 0);
                  _overallCorrectQuizzes = 0;
                  _overallTotalQuizzes = 0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppTranslations.translate(widget.languageCode, 'reset_success')),
                    backgroundColor: const Color(0xFF1E1E2F),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppTranslations.translate(widget.languageCode, 'reset_stats'),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBlock(String title, String value, IconData icon, Color color) {
    // Helper layout rendering individual metric tiles in the profile/summary dashboard.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatProgressRow(String label, int completedCount, int targetCount, Color color) {
    // Renders linear indicator lines charting progress achievements against a predefined lesson cap.
    final double progress = (completedCount / targetCount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$completedCount Completed",
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // --- GLOWING BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavigation() {
    // Renders the customized navigation footer allowing users to switch between learning views.
    final items = [
      {'icon': Icons.offline_bolt_outlined, 'activeIcon': Icons.offline_bolt, 'label': AppTranslations.translate(widget.languageCode, 'main')},
      {'icon': Icons.explore_outlined, 'activeIcon': Icons.explore, 'label': AppTranslations.translate(widget.languageCode, 'explore')},
      {'icon': Icons.search_outlined, 'activeIcon': Icons.search, 'label': AppTranslations.translate(widget.languageCode, 'search')},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': AppTranslations.translate(widget.languageCode, 'summary')},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = _selectedTabIndex == index;
              final item = items[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3B82F6).withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item['activeIcon'] as IconData : item['icon'] as IconData,
                        color: isSelected ? const Color(0xFF3B82F6) : Colors.white60,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white38,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCardTemplate(Lesson lesson) {
    // Standard template distributor parsing lessons and injecting appropriate UI layouts (MCQ, Swipe, Slides).
    switch (lesson.type) {
      case LessonType.slides:
        return TemplateSlides(
          lesson: lesson,
          onSlidesCompleted: () => _handleSlideCompleted(lesson.id, lesson.category),
        );
      case LessonType.swipe:
        return TemplateSwipe(
          lesson: lesson,
          onAnswerSubmitted: (wasCorrect) => _handleAnswerSubmitted(lesson.id, wasCorrect),
        );
      case LessonType.mcq:
        return TemplateMcq(
          lesson: lesson,
          onAnswerSubmitted: (wasCorrect) => _handleAnswerSubmitted(lesson.id, wasCorrect),
        );
    }
  }
}
