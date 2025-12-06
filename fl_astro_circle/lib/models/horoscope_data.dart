import 'package:cloud_firestore/cloud_firestore.dart';

/// Horoscope category enum
enum HoroscopeCategory { overall, love, business, health }

/// Horoscope period enum
enum HoroscopePeriod { today, tomorrow, thisWeek }

/// Extension to convert period enum to string
extension HoroscopePeriodExtension on HoroscopePeriod {
  String toFirestoreString() {
    switch (this) {
      case HoroscopePeriod.today:
        return 'today';
      case HoroscopePeriod.tomorrow:
        return 'tomorrow';
      case HoroscopePeriod.thisWeek:
        return 'this_week';
    }
  }
}

/// Category data model
class HoroscopeCategoryData {
  final int score;
  final String text;
  final String deepText;

  HoroscopeCategoryData({
    required this.score,
    required this.text,
    required this.deepText,
  });

  factory HoroscopeCategoryData.fromMap(Map<String, dynamic> map) {
    return HoroscopeCategoryData(
      score: (map['score'] as num?)?.toInt() ?? 0,
      text: map['text'] as String? ?? '',
      deepText: map['deepText'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'text': text,
      'deepText': deepText,
    };
  }
}

/// Complete horoscope data model
class HoroscopeData {
  final String zodiacSign;
  final String date;
  final HoroscopePeriod period;
  final DateTime generatedAt;
  final HoroscopeCategoryData overall;
  final HoroscopeCategoryData love;
  final HoroscopeCategoryData business;
  final HoroscopeCategoryData health;

  HoroscopeData({
    required this.zodiacSign,
    required this.date,
    required this.period,
    required this.generatedAt,
    required this.overall,
    required this.love,
    required this.business,
    required this.health,
  });

  factory HoroscopeData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final horoscopeData = data['data'] as Map<String, dynamic>;

    // Parse period from string
    HoroscopePeriod period = HoroscopePeriod.today;
    final periodStr = data['period'] as String;
    if (periodStr == 'tomorrow') {
      period = HoroscopePeriod.tomorrow;
    } else if (periodStr == 'this_week') {
      period = HoroscopePeriod.thisWeek;
    }

    return HoroscopeData(
      zodiacSign: data['zodiacSign'] as String,
      date: data['date'] as String,
      period: period,
      generatedAt: (data['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      overall: HoroscopeCategoryData.fromMap(
          horoscopeData['overall'] as Map<String, dynamic>),
      love: HoroscopeCategoryData.fromMap(
          horoscopeData['love'] as Map<String, dynamic>),
      business: HoroscopeCategoryData.fromMap(
          horoscopeData['business'] as Map<String, dynamic>),
      health: HoroscopeCategoryData.fromMap(
          horoscopeData['health'] as Map<String, dynamic>),
    );
  }

  /// Get category data by enum
  HoroscopeCategoryData getCategoryData(HoroscopeCategory category) {
    switch (category) {
      case HoroscopeCategory.overall:
        return overall;
      case HoroscopeCategory.love:
        return love;
      case HoroscopeCategory.business:
        return business;
      case HoroscopeCategory.health:
        return health;
    }
  }

  /// Get score as percentage (0.0 to 1.0)
  double getCategoryScore(HoroscopeCategory category) {
    return getCategoryData(category).score / 100.0;
  }
}
