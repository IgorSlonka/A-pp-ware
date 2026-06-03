enum LessonType {
  slides,
  swipe,
  mcq,
}

class Slide {
  final String text;
  final String chartType; // e.g. "line", "bar", "none"
  final List<double> chartData;
  final String? imagePath;

  Slide({
    required this.text,
    this.chartType = 'none',
    this.chartData = const [],
    this.imagePath,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      text: json['text'] as String,
      chartType: json['chartType'] as String? ?? 'none',
      chartData: json['chartData'] != null
          ? (json['chartData'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList()
          : const [],
      imagePath: json['imagePath'] as String?,
    );
  }
}

class SpacedRepetitionState {
  final int intervalDays;
  final double easeFactor;
  final int repetitionCount;
  final DateTime nextDueDate;

  SpacedRepetitionState({
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitionCount,
    required this.nextDueDate,
  });

  factory SpacedRepetitionState.initial() {
    return SpacedRepetitionState(
      intervalDays: 1,
      easeFactor: 2.5,
      repetitionCount: 0,
      nextDueDate: DateTime.now(),
    );
  }

  SpacedRepetitionState copyWith({
    int? intervalDays,
    double? easeFactor,
    int? repetitionCount,
    DateTime? nextDueDate,
  }) {
    return SpacedRepetitionState(
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }
}

class Lesson {
  final String id;
  final String topic;
  final String category;
  final LessonType type;
  final String title;

  // Template A: Slides-specific
  final List<Slide>? slides;

  // Template B: Swipe-specific (True/False)
  final String? question;
  final bool? correctAnswer;

  // Template C: MCQ-specific
  final List<String>? options;
  final int? correctOptionIndex;

  // Shared Quiz features
  final String? explanation;

  // Spaced Repetition State Placeholder
  SpacedRepetitionState srState;

  Lesson({
    required this.id,
    required this.topic,
    required this.category,
    required this.type,
    required this.title,
    this.slides,
    this.question,
    this.correctAnswer,
    this.options,
    this.correctOptionIndex,
    this.explanation,
    required this.srState,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    LessonType type;
    if (typeStr == 'slides') {
      type = LessonType.slides;
    } else if (typeStr == 'swipe') {
      type = LessonType.swipe;
    } else if (typeStr == 'mcq') {
      type = LessonType.mcq;
    } else {
      throw ArgumentError('Unknown lesson type: $typeStr');
    }

    return Lesson(
      id: json['id'] as String,
      topic: json['topic'] as String,
      category: json['category'] as String? ?? 'topic1',
      type: type,
      title: json['title'] as String,
      slides: json['slides'] != null
          ? (json['slides'] as List<dynamic>)
              .map((e) => Slide.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      question: json['question'] as String?,
      correctAnswer: json['correctAnswer'] as bool?,
      options: json['options'] != null
          ? (json['options'] as List<dynamic>).map((e) => e as String).toList()
          : null,
      correctOptionIndex: json['correctOptionIndex'] as int?,
      explanation: json['explanation'] as String?,
      srState: SpacedRepetitionState.initial(),
    );
  }
}
