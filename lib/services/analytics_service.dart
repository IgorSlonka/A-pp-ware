import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Responsible for sending lesson and quiz analytics events to Firestore.
/// This service separates data capture from UI logic, making it easy to
/// document completed lessons and quiz results along with timestamps,
/// category, type, and device identity.
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('deviceId');
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString('deviceId', id);
    }
    return id;
  }

  Future<List<Map<String, dynamic>>> fetchQuizEntries({
    required String login,
    required String password,
  }) async {
    final userDocId = '${login}_$password';
    try {
      final snapshot = await _firestore.collection('analytics').doc(userDocId).collection('quizzes').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // ignore: avoid_print
      print('❌ AnalyticsService.fetchQuizEntries failed: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchUserState({
    required String login,
    required String password,
  }) async {
    final userDocId = '${login}_$password';
    try {
      final snapshot = await _firestore
          .collection('analytics')
          .doc(userDocId)
          .collection('state')
          .doc('profile')
          .get();
      return snapshot.data() ?? {};
    } catch (e) {
      // ignore: avoid_print
      print('❌ AnalyticsService.fetchUserState failed: $e');
      return {};
    }
  }

  Future<void> saveUserState({
    required String login,
    required String password,
    required int xp,
    required int streak,
  }) async {
    final userDocId = '${login}_$password';
    try {
      await _firestore
          .collection('analytics')
          .doc(userDocId)
          .collection('state')
          .doc('profile')
          .set({
        'xp': xp,
        'streak': streak,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // ignore: avoid_print
      print('✅ User state saved: xp=$xp streak=$streak');
    } catch (e) {
      // ignore: avoid_print
      print('❌ AnalyticsService.saveUserState failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLessonEntries({
    required String login,
    required String password,
  }) async {
    final userDocId = '${login}_$password';
    try {
      final snapshot = await _firestore.collection('analytics').doc(userDocId).collection('lessons').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // ignore: avoid_print
      print('❌ AnalyticsService.fetchLessonEntries failed: $e');
      return [];
    }
  }

  /// Logs a quiz attempt result under `analytics/{login}/{password}/quizzes/logs`.
  /// This stores both the login and password as document fields for categorization.
  Future<void> logQuizResult({
    required String login,
    required String password,
    required String lessonId,
    required String topic,
    required String category,
    required String lessonType,
    required String title,
    required bool wasCorrect,
    required String languageCode,
    required DateTime completedAt,
  }) async {
    final deviceId = await _deviceId();
    // Use a single document id combining login and password to avoid extra intermediate collections:
    // analytics/{login}_{password}/quizzes
    final userDocId = '${login}_$password';
    final quizCollection = _firestore.collection('analytics').doc(userDocId).collection('quizzes');
    // ignore: avoid_print
    print('📊 Logging quiz: login=$login lessonId=$lessonId wasCorrect=$wasCorrect deviceId=$deviceId');

    try {
      await quizCollection.add({
        'lessonId': lessonId,
        'topic': topic,
        'category': category,
        'lessonType': lessonType,
        'title': title,
        'wasCorrect': wasCorrect,
        'languageCode': languageCode,
        'completedAt': completedAt.toUtc(),
        'deviceId': deviceId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // ignore: avoid_print
      print('✅ Quiz logged successfully');
    } catch (e) {
      // ignore: avoid_print
      print('❌ AnalyticsService.logQuizResult failed: $e');
    }
  }

  /// Logs the completion of a lesson under `analytics/{login}/{password}/lessons/logs`.
  Future<void> logLessonCompletion({
    required String login,
    required String password,
    required String lessonId,
    required String topic,
    required String category,
    required String lessonType,
    required String title,
    required String languageCode,
    required DateTime completedAt,
  }) async {
    final deviceId = await _deviceId();
    final userDocId = '${login}_$password';
    final completionCollection = _firestore.collection('analytics').doc(userDocId).collection('lessons');
    // ignore: avoid_print
    print('📚 Logging lesson: login=$login lessonId=$lessonId title=$title deviceId=$deviceId');

    try {
      await completionCollection.add({
        'lessonId': lessonId,
        'topic': topic,
        'category': category,
        'lessonType': lessonType,
        'title': title,
        'languageCode': languageCode,
        'completedAt': completedAt.toUtc(),
        'deviceId': deviceId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // ignore: avoid_print
      print('✅ Lesson logged successfully');
    } catch (e) {
      // ignore: avoid_print
      print('❌ AnalyticsService.logLessonCompletion failed: $e');
    }
  }
}
