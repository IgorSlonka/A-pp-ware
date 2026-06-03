import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/lesson_model.dart';

class FeedEngine {
  List<Lesson> _lessons = [];
  final Random _random = Random();

  List<Lesson> get lessons => _lessons;

  /// Loads lessons from assets/data/lessons_$langCode.json
  Future<void> loadLessons(String langCode) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/lessons_$langCode.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      _lessons = jsonList.map((item) => Lesson.fromJson(item as Map<String, dynamic>)).toList();
      print("SUCCESSFULLY LOADED ${_lessons.length} LESSONS FROM JSON FOR LANG: $langCode");
    } catch (e, stack) {
      print("ERROR LOADING LESSONS JSON FOR LANG $langCode: $e");
      print(stack);
      // Fallback: If loading assets fails or in environment initialization
      _lessons = _getHardcodedFallbackLessons();
    }
  }

  /// Active method: returns a lesson selected randomly (RNG) from the loaded pool
  Lesson getNextLesson() {
    if (_lessons.isEmpty) {
      throw StateError("Lessons pool is empty. Please load lessons first.");
    }
    // Return a random lesson from the pool
    final index = _random.nextInt(_lessons.length);
    return _lessons[index];
  }

  /// STUB PLACEHOLDER: Future Anki-style Spaced Repetition selector
  /// In the future, this will replace getNextLesson() to fetch cards whose
  /// srState.nextDueDate is before/closest to DateTime.now(), or calculate
  /// a weighted queue based on card intervals and ease factors.
  Lesson getNextLessonSpacedRepetition() {
    // ----------------------------------------------------
    // TODO: Implement actual spaced repetition queue.
    // 
    // Example pseudocode:
    // 1. Filter lessons due for review: 
    //    List<Lesson> dueLessons = _lessons.where((l) => l.srState.nextDueDate.isBefore(DateTime.now())).toList();
    // 2. If dueLessons is not empty:
    //    - Sort by priority or return the most urgent.
    // 3. If no cards are due:
    //    - Introduce new cards or fallback to a standard random pool.
    // ----------------------------------------------------
    
    // Active Fallback to RNG as specified in user request
    return getNextLesson();
  }

  /// Hook to record card reviews (User answered True/False or MCQ)
  /// Updates the lesson's SpacedRepetitionState.
  void recordReview(String lessonId, bool wasCorrect) {
    final lessonIndex = _lessons.indexWhere((l) => l.id == lessonId);
    if (lessonIndex == -1) return;

    final lesson = _lessons[lessonIndex];
    final currentState = lesson.srState;

    // SuperMemo-2 (SM-2) simplified algorithm stub for future extension:
    int nextInterval;
    double nextEase;
    int nextRepCount;

    if (wasCorrect) {
      nextRepCount = currentState.repetitionCount + 1;
      if (nextRepCount == 1) {
        nextInterval = 1; // 1 day
      } else if (nextRepCount == 2) {
        nextInterval = 6; // 6 days
      } else {
        nextInterval = (currentState.intervalDays * currentState.easeFactor).round();
      }
      nextEase = currentState.easeFactor + 0.1;
    } else {
      nextRepCount = 0;
      nextInterval = 1; // reset to 1 day
      nextEase = max(1.3, currentState.easeFactor - 0.2); // ease floor at 1.3
    }

    final nextDueDate = DateTime.now().add(Duration(days: nextInterval));

    // Update in-memory state
    lesson.srState = currentState.copyWith(
      intervalDays: nextInterval,
      easeFactor: nextEase,
      repetitionCount: nextRepCount,
      nextDueDate: nextDueDate,
    );

    // Logging progression to assist developer visual debugging
    print("SR UPDATE: Card ${lesson.id} review recorded (Correct: $wasCorrect). "
          "Next review interval: $nextInterval day(s), Ease: ${nextEase.toStringAsFixed(2)}, Due: $nextDueDate");
  }

  /// Provides hardcoded data in case asset loader encounters issues in simple runners
  List<Lesson> _getHardcodedFallbackLessons() {
    return [
      Lesson(
        id: "fb_001",
        topic: "Lorem Ipsum",
        category: "topic1",
        type: LessonType.slides,
        title: "Lorem Ipsum Dolor",
        slides: [
          Slide(
            text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            chartType: "line",
            chartData: [10, 20, 30, 40],
          )
        ],
        srState: SpacedRepetitionState.initial(),
      ),
      Lesson(
        id: "fb_002",
        topic: "Lorem Ipsum",
        category: "topic2",
        type: LessonType.swipe,
        title: "Lorem Ipsum Quiz",
        question: "Lorem ipsum dolor sit amet, is this statement True? (True/False)",
        correctAnswer: true,
        explanation: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
        srState: SpacedRepetitionState.initial(),
      ),
      Lesson(
        id: "fb_003",
        topic: "Lorem Ipsum",
        category: "topic3",
        type: LessonType.mcq,
        title: "Lorem Ipsum MCQ",
        question: "Lorem ipsum dolor sit amet, consectetur adipiscing elit?",
        options: ["Lorem Ipsum Option A", "Lorem Ipsum Option B", "Lorem Ipsum Option C"],
        correctOptionIndex: 0,
        explanation: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
        srState: SpacedRepetitionState.initial(),
      )
    ];
  }
}
