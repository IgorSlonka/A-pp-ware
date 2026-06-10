/// This file defines the FeedEngine class, which handles fetching, managing, and indexing lesson content.
/// It supports loading localized lesson data from assets and provides fallback hardcoded lessons in case of I/O failures.
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/lesson_model.dart';
import '../marcin_srs_klasa/review_card_class.dart';

class FeedEngine {
  List<Lesson> _lessons = [];
  List<reviewCard> _reviewCards = [];
  final Random _random = Random();

  List<Lesson> get lessons => _lessons;

  /// Loads lessons from assets/data/lessons_$langCode.json
  Future<void> loadLessons(String langCode) async {
    /// Loads lessons from assets/data/lessons_$langCode.json and parses the localized contents into Lesson models.
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

  /// Loads reviewCards from assets/data/review_cards.json
  Future<void> loadReviewCards() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/review_cards.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      _reviewCards = jsonList.map((item) => reviewCard.fromJson(item as Map<String, dynamic>)).toList();
      print("SUCCESSFULLY LOADED ${_reviewCards.length}");
    } catch (e, stack) {
      print("ERROR LOADING REVIEW CARDS");
      print(stack);
    }
  }
  /// Saves reviewCards
  Future<void> saveReviewCards() async {
    ///
  }
  /// Active method: returns a lesson selected randomly (RNG) from the loaded pool
  Lesson getNextLesson() {
    /// Selects and returns a random lesson from the available pool.
    if (_lessons.isEmpty) {
      throw StateError("Lessons pool is empty. Please load lessons first.");
    }
    // Return a random lesson from the pool
    final index = _random.nextInt(_lessons.length);
    return _lessons[index];
  }


  Lesson getNextLessonSpacedRepetition() {
    final now = DateTime.now();

    ///Picks cards whose nextReview is due
    final dueCards = _reviewCards.where(
      (card) => card.nextReview.isBefore(now),
    ).toList();

    if(dueCards.isNotEmpty){
      ///Sorts with respect to nextReview
      dueCards.sort(
        (a,b) => a.nextReview.compareTo(b.nextReview),
      );

      ///Return the lesson corresponding to the id of the first due card
      final nextCard = dueCards.first;
      return lessons.firstWhere(
        (lesson) => lesson.id == nextCard.id,
      );
    }
    return getNextLesson();
  }

  /// Hook to record card reviews (User answered True/False or MCQ)
  void recordReview(String lessonId, bool wasCorrect) {
    /// Records user performance feedback to guide spaced repetition engines.
    ///Pick card correspoding to lesson ID
    final card = _reviewCards.firstWhere(
        (c) => c.id == lessonId,
    );
    final now = DateTime.now();
    ///increment repetitions on correct answer, set repetitions to 0 on wrong answer
    if(wasCorrect){
      card.repetitions ++;

    } else{
      card.repetitions = 0;
    }
    ///Udpate nextReview variable based on the switch case of repetitions inside getInterval() in the reviewCard class definition
    card.nextReview = now.add(card.getInterval());

    saveReviewCards();
  }

  /// Provides hardcoded data in case asset loader encounters issues in simple runners
  List<Lesson> _getHardcodedFallbackLessons() {
    /// Returns default mock data objects if local JSON databases fail to load or resolve.
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
