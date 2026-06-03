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

  /// STUB PLACEHOLDER: Fallback to random selection from json
  Lesson getNextLessonSpacedRepetition() {
    return getNextLesson();
  }

  /// Hook to record card reviews (User answered True/False or MCQ)
  /// Simplified placeholder function
  void recordReview(String lessonId, bool wasCorrect) {
    print("REVIEW RECORDED: Card $lessonId (Correct: $wasCorrect). Spaced repetition is disabled, using fallback random selection.");
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
      )
    ];
  }
}
