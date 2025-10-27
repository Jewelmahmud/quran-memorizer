class RecitationResponseModel {
  final String sessionId;
  final double pronunciationScore;
  final List<String> feedback;
  final List<String> phonemeErrors;
  final List<String> tajweedViolations;

  RecitationResponseModel({
    required this.sessionId,
    required this.pronunciationScore,
    required this.feedback,
    required this.phonemeErrors,
    required this.tajweedViolations,
  });

  factory RecitationResponseModel.fromJson(Map<String, dynamic> json) {
    return RecitationResponseModel(
      sessionId: json['session_id'] as String,
      pronunciationScore: (json['pronunciation_score'] as num).toDouble(),
      feedback: List<String>.from(json['feedback'] as List),
      phonemeErrors: List<String>.from(json['phoneme_errors'] as List),
      tajweedViolations: List<String>.from(json['tajweed_violations'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'pronunciation_score': pronunciationScore,
      'feedback': feedback,
      'phoneme_errors': phonemeErrors,
      'tajweed_violations': tajweedViolations,
    };
  }
}
