import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_astro_circle/models/horoscope_data.dart';

/// Service for fetching horoscope data from Firestore
class HoroscopeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get horoscope for a specific zodiac sign, date, and period
  /// Returns null if not found
  Future<HoroscopeData?> getHoroscope({
    required String zodiacSign,
    required String date, // Format: YYYY-MM-DD
    required HoroscopePeriod period,
  }) async {
    try {
      final documentId = '${zodiacSign}_${date}_${period.toFirestoreString()}';
      final doc = await _firestore.collection('horoscopes').doc(documentId).get();

      if (!doc.exists) {
        print('Horoscope not found: $documentId');
        return null;
      }

      return HoroscopeData.fromFirestore(doc);
    } catch (e) {
      print('Error fetching horoscope: $e');
      return null;
    }
  }

  /// Get horoscope for today (uses local timezone)
  Future<HoroscopeData?> getTodayHoroscope({
    required String zodiacSign,
    required HoroscopePeriod period,
  }) async {
    final now = DateTime.now();
    String dateStr;

    // Calculate the date based on period
    if (period == HoroscopePeriod.today) {
      dateStr = _formatDate(now);
    } else if (period == HoroscopePeriod.tomorrow) {
      final tomorrow = now.add(const Duration(days: 1));
      dateStr = _formatDate(tomorrow);
    } else {
      // For this_week, use today's date
      dateStr = _formatDate(now);
    }

    return getHoroscope(
      zodiacSign: zodiacSign,
      date: dateStr,
      period: period,
    );
  }

  /// Get all three periods (today, tomorrow, this_week) for a zodiac sign
  Future<Map<HoroscopePeriod, HoroscopeData?>> getAllPeriodsForToday({
    required String zodiacSign,
  }) async {
    final results = <HoroscopePeriod, HoroscopeData?>{};

    for (final period in HoroscopePeriod.values) {
      results[period] = await getTodayHoroscope(
        zodiacSign: zodiacSign,
        period: period,
      );
    }

    return results;
  }

  /// Stream horoscope updates (real-time)
  Stream<HoroscopeData?> streamHoroscope({
    required String zodiacSign,
    required String date,
    required HoroscopePeriod period,
  }) {
    final documentId = '${zodiacSign}_${date}_${period.toFirestoreString()}';

    return _firestore
        .collection('horoscopes')
        .doc(documentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }
      return HoroscopeData.fromFirestore(doc);
    });
  }

  /// Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get the current user's zodiac sign from their birth date
  /// This is a helper method - you may want to store this in user profile
  static String getZodiacSignFromDate(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'aries';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'taurus';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 'gemini';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 'cancer';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 'leo';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 'virgo';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 'libra';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'scorpio';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'sagittarius';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'capricorn';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'aquarius';
    } else {
      return 'pisces';
    }
  }
}
