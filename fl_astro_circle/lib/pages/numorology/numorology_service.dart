import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_astro_circle/config/api_config.dart';

/// Результат нумерологического анализа
class NumerologyResult {
  final int luckyNumber;
  final String birthDate;
  final Map<String, double> traits; // название черты -> процент (0.0-1.0)
  final String aboutCharacter;
  final String aboutBehavior;
  final String aboutResponsibility;

  NumerologyResult({
    required this.luckyNumber,
    required this.birthDate,
    required this.traits,
    required this.aboutCharacter,
    required this.aboutBehavior,
    required this.aboutResponsibility,
  });
}

/// Сервис для нумерологического анализа через OpenRouter
class NumerologyService {
  final String _apiKey;
  final String _baseUrl;
  final String _model;

  NumerologyService({
    String? apiKey,
    String? baseUrl,
    String? model,
  })  : _apiKey = apiKey ?? ApiConfig.openRouterApiKey,
        _baseUrl = baseUrl ?? ApiConfig.openRouterBaseUrl,
        _model = model ?? ApiConfig.aiModel;

  /// Вычислить число судьбы (Life Path Number) из даты рождения
  int calculateLifePathNumber(DateTime birthDate) {
    int day = birthDate.day;
    int month = birthDate.month;
    int year = birthDate.year;

    // Суммируем все цифры даты рождения
    int sum = _sumDigits(day) + _sumDigits(month) + _sumDigits(year);

    // Редуцируем до одной цифры (кроме мастер-чисел 11, 22, 33)
    while (sum > 9 && sum != 11 && sum != 22 && sum != 33) {
      sum = _sumDigits(sum);
    }

    // Для простоты возвращаем число от 1 до 9
    if (sum > 9) {
      sum = _sumDigits(sum);
    }

    return sum == 0 ? 1 : sum;
  }

  int _sumDigits(int number) {
    int sum = 0;
    while (number > 0) {
      sum += number % 10;
      number ~/= 10;
    }
    return sum;
  }

  /// Генерация нумерологического анализа
  Future<NumerologyResult> generateNumerology({
    required DateTime birthDate,
    required String language,
  }) async {
    final luckyNumber = calculateLifePathNumber(birthDate);
    final formattedDate =
        '${birthDate.day.toString().padLeft(2, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.year}';

    final prompt = '''You are an expert numerologist. Analyze the person with Life Path Number $luckyNumber (born $formattedDate).

Provide a detailed numerology reading in $language with the following EXACT JSON structure:

{
  "traits": {
    "funny": 0.85,
    "obedient": 0.70,
    "honest": 0.90,
    "responsible": 0.75,
    "hard_working": 0.80,
    "smart": 0.88
  },
  "aboutCharacter": "2-3 paragraphs about character based on this number...",
  "aboutBehavior": "2-3 paragraphs about behavior patterns...",
  "aboutResponsibility": "2-3 paragraphs about responsibility and life purpose..."
}

IMPORTANT:
- Trait values must be between 0.5 and 0.99
- Make the analysis personal and insightful based on the Life Path Number $luckyNumber
- Write about_character, about_behavior, about_responsibility in $language
- Return ONLY valid JSON, no other text''';

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are a mystical numerologist. Output ONLY valid JSON, no markdown, no explanations.'
      },
      {'role': 'user', 'content': prompt},
    ];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': ApiConfig.appUrl,
          'X-Title': ApiConfig.appName,
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1200,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];

        if (content != null) {
          return _parseNumerologyResponse(
            content as String,
            luckyNumber,
            formattedDate,
          );
        }
        throw NumerologyException('Empty response from AI');
      } else if (response.statusCode == 401) {
        throw NumerologyException('Invalid API key');
      } else if (response.statusCode == 429) {
        throw NumerologyException('Rate limit exceeded. Try again later.');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw NumerologyException('API error: $errorMessage');
      }
    } on http.ClientException catch (e) {
      throw NumerologyException('Network error: ${e.message}');
    } on FormatException {
      throw NumerologyException('Invalid response format');
    }
  }

  NumerologyResult _parseNumerologyResponse(
    String content,
    int luckyNumber,
    String birthDate,
  ) {
    // Очищаем ответ от возможных markdown-обёрток
    String cleaned = content.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();

    try {
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      // Парсим traits
      final traitsJson = json['traits'] as Map<String, dynamic>? ?? {};
      final traits = <String, double>{};

      final defaultTraits = {
        'funny': 0.75,
        'obedient': 0.70,
        'honest': 0.80,
        'responsible': 0.75,
        'hard_working': 0.78,
        'smart': 0.82,
      };

      for (final entry in defaultTraits.entries) {
        final value = traitsJson[entry.key];
        if (value is num) {
          traits[entry.key] = value.toDouble().clamp(0.0, 1.0);
        } else {
          traits[entry.key] = entry.value;
        }
      }

      return NumerologyResult(
        luckyNumber: luckyNumber,
        birthDate: birthDate,
        traits: traits,
        aboutCharacter: json['aboutCharacter'] as String? ??
            _getDefaultCharacterText(luckyNumber),
        aboutBehavior: json['aboutBehavior'] as String? ??
            _getDefaultBehaviorText(luckyNumber),
        aboutResponsibility: json['aboutResponsibility'] as String? ??
            _getDefaultResponsibilityText(luckyNumber),
      );
    } catch (e) {
      // Если парсинг не удался, возвращаем дефолтные значения
      return NumerologyResult(
        luckyNumber: luckyNumber,
        birthDate: birthDate,
        traits: {
          'funny': 0.75,
          'obedient': 0.70,
          'honest': 0.80,
          'responsible': 0.75,
          'hard_working': 0.78,
          'smart': 0.82,
        },
        aboutCharacter: _getDefaultCharacterText(luckyNumber),
        aboutBehavior: _getDefaultBehaviorText(luckyNumber),
        aboutResponsibility: _getDefaultResponsibilityText(luckyNumber),
      );
    }
  }

  String _getDefaultCharacterText(int number) {
    final descriptions = {
      1: 'People with Life Path 1 are natural leaders with strong willpower and determination. They possess an independent spirit and original ideas.',
      2: 'Those with Life Path 2 are diplomatic and sensitive souls. They excel at cooperation and bring harmony to their surroundings.',
      3: 'Life Path 3 individuals are creative and expressive. They have a natural gift for communication and artistic endeavors.',
      4: 'People with Life Path 4 are practical and hardworking. They build solid foundations and value stability and order.',
      5: 'Those with Life Path 5 crave freedom and adventure. They are versatile and adaptable, embracing change with enthusiasm.',
      6: 'Life Path 6 individuals are nurturing and responsible. They have a deep sense of duty to family and community.',
      7: 'People with Life Path 7 are analytical and introspective. They seek knowledge and spiritual understanding.',
      8: 'Those with Life Path 8 are ambitious and goal-oriented. They possess natural business acumen and leadership abilities.',
      9: 'Life Path 9 individuals are compassionate and humanitarian. They have a universal outlook and desire to serve others.',
    };
    return descriptions[number] ?? descriptions[1]!;
  }

  String _getDefaultBehaviorText(int number) {
    final descriptions = {
      1: 'In daily life, they take initiative and prefer to work independently. They may sometimes appear stubborn but their determination leads to success.',
      2: 'They naturally mediate conflicts and create peaceful environments. They work best in partnerships and collaborative settings.',
      3: 'They bring joy and optimism wherever they go. Their social nature makes them excellent communicators and entertainers.',
      4: 'They approach tasks methodically and with great attention to detail. Their reliability makes them trusted by others.',
      5: 'They adapt quickly to new situations and enjoy variety. They may resist routine but thrive in dynamic environments.',
      6: 'They prioritize the well-being of loved ones. Their protective nature makes them excellent caregivers and advisors.',
      7: 'They often need solitude to recharge and reflect. Their quiet demeanor hides a profound depth of thought.',
      8: 'They set high standards and work tirelessly to achieve them. Their confidence inspires others to follow their lead.',
      9: 'They often put others needs before their own. Their generous spirit attracts people seeking guidance and support.',
    };
    return descriptions[number] ?? descriptions[1]!;
  }

  String _getDefaultResponsibilityText(int number) {
    final descriptions = {
      1: 'Your life purpose is to develop individuality and self-reliance. You are here to pioneer new paths and inspire others through your courage.',
      2: 'Your mission is to bring balance and cooperation to the world. You serve as a bridge between opposing forces, creating harmony.',
      3: 'You are meant to express creativity and inspire joy. Your purpose involves using your talents to uplift and entertain others.',
      4: 'Your path involves building lasting structures and systems. You create security and stability for yourself and others.',
      5: 'You are here to experience life fully and promote freedom. Your purpose is to help others embrace change and growth.',
      6: 'Your responsibility is to nurture and protect. You serve as a pillar of support for family and community.',
      7: 'Your purpose is the pursuit of wisdom and truth. You are meant to delve deep and share your insights with the world.',
      8: 'You are here to master the material world and use resources wisely. Your success should benefit the greater good.',
      9: 'Your life mission is humanitarian service. You are meant to give selflessly and work for the betterment of humanity.',
    };
    return descriptions[number] ?? descriptions[1]!;
  }

  /// Генерация детального анализа для категории
  Future<String> generateNumerologyDetail({
    required int luckyNumber,
    required String birthDate,
    required NumerologyCategory category,
    required String language,
  }) async {
    final categoryName = _getCategoryName(category);
    final categoryPrompt = _getCategoryDetailPrompt(category, luckyNumber);

    final prompt = '''You are a master numerologist. Provide a DETAILED, IN-DEPTH analysis of $categoryName for Life Path Number $luckyNumber (born $birthDate).

ANALYSIS FOCUS:
$categoryPrompt

STRICT REQUIREMENTS:
- Write 5-8 substantial paragraphs
- Include specific numerological influences based on this number
- Provide practical advice and wisdom
- Use beautiful, poetic but accessible language
- Make it feel personal and transformative
- Write in $language
- DO NOT include any special characters, tags, or markers
- DO NOT start with greetings or introductions
- Start directly with the analysis

OUTPUT: Pure text only, no formatting tags.''';

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are a master numerologist. Output ONLY the requested analysis, no tags, no markers, no special characters. Write naturally and personally.'
      },
      {'role': 'user', 'content': prompt},
    ];

    return _sendRawMessage(messages, maxTokens: 1500);
  }

  Future<String> _sendRawMessage(List<Map<String, String>> messages,
      {int maxTokens = 500}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': ApiConfig.appUrl,
          'X-Title': ApiConfig.appName,
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': maxTokens,
          'temperature': 0.85,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null) {
          return _cleanResponse(content as String);
        }
        throw NumerologyException('Empty response from AI');
      } else if (response.statusCode == 401) {
        throw NumerologyException('Invalid API key');
      } else if (response.statusCode == 429) {
        throw NumerologyException('Rate limit exceeded. Try again later.');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw NumerologyException('API error: $errorMessage');
      }
    } on http.ClientException catch (e) {
      throw NumerologyException('Network error: ${e.message}');
    } on FormatException {
      throw NumerologyException('Invalid response format');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw NumerologyException('Request timeout. Please try again.');
      }
      rethrow;
    }
  }

  String _cleanResponse(String response) {
    String cleaned = response.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(cleaned.indexOf('\n') + 1);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.lastIndexOf('```'));
    }
    return cleaned.trim();
  }

  String _getCategoryName(NumerologyCategory category) {
    switch (category) {
      case NumerologyCategory.character:
        return 'Character & Personality';
      case NumerologyCategory.behavior:
        return 'Behavior & Life Patterns';
      case NumerologyCategory.responsibility:
        return 'Life Purpose & Responsibility';
    }
  }

  String _getCategoryDetailPrompt(NumerologyCategory category, int number) {
    switch (category) {
      case NumerologyCategory.character:
        return '''Focus on:
- Core personality traits defined by Life Path $number
- Inner strengths and natural talents
- How this number shapes emotional responses
- Hidden aspects of character that may surprise others
- The shadow side and how to overcome it
- Natural gifts and abilities that come easily
- How others perceive someone with this number
- The unique charm and magnetism of this life path''';

      case NumerologyCategory.behavior:
        return '''Focus on:
- Daily habits and routines influenced by number $number
- Communication style and social interactions
- Decision-making patterns and thought processes
- How this number handles stress and challenges
- Relationship dynamics and attachment style
- Work habits and professional behavior
- Reactions to change and uncertainty
- The way this number expresses love and care''';

      case NumerologyCategory.responsibility:
        return '''Focus on:
- The sacred life mission of number $number
- Karmic lessons and soul purpose
- How to fulfill one's highest potential
- Responsibilities to self and others
- The legacy this number is meant to leave
- Spiritual growth opportunities
- How to align actions with life purpose
- The greater good this number serves''';
    }
  }
}

/// Категории нумерологического анализа
enum NumerologyCategory {
  character,
  behavior,
  responsibility,
}

/// Исключение для ошибок нумерологии
class NumerologyException implements Exception {
  final String message;

  NumerologyException(this.message);

  @override
  String toString() => message;
}



