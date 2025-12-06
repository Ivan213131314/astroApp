import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_astro_circle/config/api_config.dart';

/// Категории натальной карты
enum NatalChartCategory {
  sunSign,     // Core identity, life purpose
  moonSign,    // Emotional nature, inner world
  risingSign,  // Outer personality, first impressions
}

/// Сервис для генерации AI контента натальной карты
class NatalChartAiService {
  final String _apiKey;
  final String _baseUrl;
  final String _model;

  NatalChartAiService({
    String? apiKey,
    String? baseUrl,
    String? model,
  })  : _apiKey = apiKey ?? ApiConfig.openRouterApiKey,
        _baseUrl = baseUrl ?? ApiConfig.openRouterBaseUrl,
        _model = model ?? ApiConfig.aiModel;

  String _getCategoryName(NatalChartCategory category) {
    switch (category) {
      case NatalChartCategory.sunSign:
        return 'Sun Sign';
      case NatalChartCategory.moonSign:
        return 'Moon Sign';
      case NatalChartCategory.risingSign:
        return 'Rising Sign (Ascendant)';
    }
  }

  String _getCategoryDescription(NatalChartCategory category) {
    switch (category) {
      case NatalChartCategory.sunSign:
        return '''Focus on:
- Core identity and ego
- Life purpose and direction
- Fundamental character traits
- How they express their willpower
- Their creative essence''';
      case NatalChartCategory.moonSign:
        return '''Focus on:
- Emotional nature and reactions
- Inner world and subconscious patterns
- Instinctive behaviors and needs
- Relationship with nurturing and comfort
- Hidden feelings and intuition''';
      case NatalChartCategory.risingSign:
        return '''Focus on:
- First impressions and appearance
- How others perceive them
- Approach to new situations
- Physical mannerisms and style
- The mask they show the world''';
    }
  }

  /// Генерация тизера для одной категории (1-2 абзаца)
  Future<String> generateTeaser({
    required NatalChartCategory category,
    required String sign,
    required String language,
    String? name,
    String? birthDate,
    String? birthTime,
    String? location,
  }) async {
    final categoryName = _getCategoryName(category);
    final personInfo = _formatPersonInfo(name, birthDate, birthTime, location);

    final prompt = '''Generate a SHORT, INTRIGUING teaser about a person's $categoryName in astrology.

PERSON INFO:
$personInfo
$categoryName: $sign

STRICT REQUIREMENTS:
- Write exactly 1-2 short paragraphs (3-5 sentences total)
- Use their name naturally in the text (if provided)
- Be mysterious and captivating - make the reader WANT to know more
- Hint at secrets, hidden traits, or surprising revelations about their $categoryName
- End with a hook that creates curiosity
- Write in $language
- DO NOT include any special characters, tags, or markers
- DO NOT start with greetings or introductions
- Start directly with the content

OUTPUT: Pure text only, no formatting tags.''';

    return _sendMessage(prompt, maxTokens: 300);
  }

  /// Генерация детального анализа (5-10 абзацев)
  Future<String> generateDetail({
    required NatalChartCategory category,
    required String sign,
    required String language,
    String? name,
    String? birthDate,
    String? birthTime,
    String? location,
  }) async {
    final categoryName = _getCategoryName(category);
    final categoryDescription = _getCategoryDescription(category);
    final personInfo = _formatPersonInfo(name, birthDate, birthTime, location);

    final prompt = '''Provide a DETAILED, IN-DEPTH analysis of a person's $categoryName placement.

PERSON INFO:
$personInfo
$categoryName: $sign

ANALYSIS FOCUS:
$categoryDescription

STRICT REQUIREMENTS:
- Write 5-10 substantial paragraphs
- Use their name naturally throughout (if provided)
- Include specific planetary influences
- Provide practical advice and wisdom
- Use beautiful, poetic but accessible language
- Make it feel personal and transformative
- Write in $language
- DO NOT include any special characters, tags, or markers
- DO NOT start with greetings or introductions
- Start directly with the analysis

OUTPUT: Pure text only, no formatting tags.''';

    return _sendMessage(prompt, maxTokens: 1500);
  }

  /// Генерация всех трех тизеров параллельно
  Future<NatalChartTeasers> generateAllTeasers({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    required String language,
    String? name,
    String? birthDate,
    String? birthTime,
    String? location,
  }) async {
    final results = await Future.wait([
      generateTeaser(
        category: NatalChartCategory.sunSign,
        sign: sunSign,
        language: language,
        name: name,
        birthDate: birthDate,
        birthTime: birthTime,
        location: location,
      ),
      generateTeaser(
        category: NatalChartCategory.moonSign,
        sign: moonSign,
        language: language,
        name: name,
        birthDate: birthDate,
        birthTime: birthTime,
        location: location,
      ),
      generateTeaser(
        category: NatalChartCategory.risingSign,
        sign: risingSign,
        language: language,
        name: name,
        birthDate: birthDate,
        birthTime: birthTime,
        location: location,
      ),
    ]);

    return NatalChartTeasers(
      sunTeaser: results[0],
      moonTeaser: results[1],
      risingTeaser: results[2],
    );
  }

  String _formatPersonInfo(String? name, String? birthDate, String? birthTime, String? location) {
    final parts = <String>[];
    if (name != null && name.isNotEmpty) {
      parts.add('Name: $name');
    }
    if (birthDate != null && birthDate.isNotEmpty) {
      parts.add('Birth Date: $birthDate');
    }
    if (birthTime != null && birthTime.isNotEmpty) {
      parts.add('Birth Time: $birthTime');
    }
    if (location != null && location.isNotEmpty) {
      parts.add('Birth Location: $location');
    }
    return parts.join('\n');
  }

  Future<String> _sendMessage(String prompt, {int maxTokens = 500}) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': 'You are a master astrologer. Output ONLY the requested analysis, no tags, no markers, no special characters. Never use [BOS], [EOS], <bot>, </bot> or similar tokens. Write naturally and personally.'
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
          'max_tokens': maxTokens,
          'temperature': 0.85,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null) {
          return _cleanAiResponse(content as String);
        }
        throw NatalChartAiException('Empty response from AI');
      } else if (response.statusCode == 401) {
        throw NatalChartAiException('Invalid API key');
      } else if (response.statusCode == 429) {
        throw NatalChartAiException('Rate limit exceeded. Please try again later.');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw NatalChartAiException('API error (${response.statusCode}): $errorMessage');
      }
    } on http.ClientException catch (e) {
      throw NatalChartAiException('Network error: ${e.message}');
    } on FormatException {
      throw NatalChartAiException('Invalid response format');
    }
  }

  String _cleanAiResponse(String response) {
    final patterns = [
      RegExp(r'<s>', caseSensitive: false),
      RegExp(r'</s>', caseSensitive: false),
      RegExp(r'\[BOS\]', caseSensitive: false),
      RegExp(r'\[EOS\]', caseSensitive: false),
      RegExp(r'\[BOT\]', caseSensitive: false),
      RegExp(r'\[/BOT\]', caseSensitive: false),
      RegExp(r'<bot>', caseSensitive: false),
      RegExp(r'</bot>', caseSensitive: false),
      RegExp(r'<\|im_start\|>', caseSensitive: false),
      RegExp(r'<\|im_end\|>', caseSensitive: false),
      RegExp(r'<\|endoftext\|>', caseSensitive: false),
      RegExp(r'\[INST\]', caseSensitive: false),
      RegExp(r'\[/INST\]', caseSensitive: false),
      RegExp(r'<<SYS>>', caseSensitive: false),
      RegExp(r'<</SYS>>', caseSensitive: false),
      RegExp(r'<\|assistant\|>', caseSensitive: false),
      RegExp(r'<\|user\|>', caseSensitive: false),
      RegExp(r'<\|system\|>', caseSensitive: false),
    ];

    String cleaned = response;
    for (final pattern in patterns) {
      cleaned = cleaned.replaceAll(pattern, '');
    }

    cleaned = cleaned.trim();
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return cleaned;
  }
}

/// Результат генерации всех тизеров
class NatalChartTeasers {
  final String sunTeaser;
  final String moonTeaser;
  final String risingTeaser;

  NatalChartTeasers({
    required this.sunTeaser,
    required this.moonTeaser,
    required this.risingTeaser,
  });
}

/// Исключение для ошибок AI сервиса
class NatalChartAiException implements Exception {
  final String message;

  NatalChartAiException(this.message);

  @override
  String toString() => message;
}



