class reviewCard {
  final String id;
  int repetitions;
  DateTime lastReview;
  DateTime nextReview;

  reviewCard({

    required this.id,
    required this.repetitions,
    required this.lastReview,
    required this.nextReview,

  });

  factory reviewCard.fromJson(Map<String, dynamic> json){

    return reviewCard(
      id : json['id'],
      repetitions: json['repetitions'] as int ,
      lastReview: DateTime.parse(json['lastReview'] as String),
      nextReview: DateTime.parse(json['nextReview'] as String),
    );
  }
///Instructs how to save a card to a json file
  Map<String, dynamic> toJson(){
    return {
      "id" : id,
      "repetitions" : repetitions,
      "lastReview" : lastReview.toIso8601String(),
      "nextReview" : nextReview.toIso8601String(),
    };
  }

  ///Increases days until next review based on the number of repetitions
  Duration getInterval() {
    switch (repetitions) {
      case 1:
        return Duration(days: 1);
      case 2:
        return Duration(days: 4);
      case 3:
        return Duration(days: 7);
      case 4:
        return Duration(days: 14);
      case 5:
        return Duration(days: 30);
      default:
        return Duration(days: 1);

    }
  }
}