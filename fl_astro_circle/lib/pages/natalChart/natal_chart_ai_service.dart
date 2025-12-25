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
        return '''- Core identity and ego structure
- Life direction and inner motivation
- How willpower is expressed and blocked
- Psychological patterns behind control, desire, and fear
- Creative and destructive tendencies of this placement''';
      case NatalChartCategory.moonSign:
        return '''- Emotional nature and unconscious reactions
- Inner world and subconscious patterns
- Instinctive behaviors, needs, and coping mechanisms
- Relationship with nurturing, comfort, and emotional safety
- Hidden feelings, intuition, and vulnerability''';
      case NatalChartCategory.risingSign:
        return '''- First impressions and social persona
- How others perceive them vs. who they really are
- Approach to new situations and self-presentation
- Physical mannerisms and unconscious body language
- The mask they show the world and what it hides''';
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

    final prompt = '''Generate a ONE-SENTENCE astrology teaser written in a provocative, tabloid-style tone.

PERSON INFO:
$personInfo
PLACEMENT:
$categoryName: $sign

STRICT REQUIREMENTS:
- Write EXACTLY ONE sentence.
- Use simple, clear language (no complex structures).
- The sentence must feel unfinished or unsettling.
- Do NOT explain what is hidden.
- Do NOT name traits directly.
- Hint that something important is being hidden, suppressed, or avoided.
- Suggest that this hidden aspect affects relationships, choices, or how others perceive them — without explaining how.
- Create intrigue, tension, or quiet suspicion.
- End the sentence so it feels like something is missing.
- Write in $language.
- No metaphors, no poetic overgrowth, no explanations.
- Output plain text only.''';

    return _sendMessage(prompt, maxTokens: 100);
  }

  /// Генерация детального анализа (4 параграфа)
  Future<String> generateDetail({
    required NatalChartCategory category,
    required String sign,
    required String language,
    String? name,
    String? birthDate,
    String? birthTime,
    String? location,
    String? teaser,
  }) async {
    final categoryName = _getCategoryName(category);
    final categoryDescription = _getCategoryDescription(category);
    final personInfo = _formatPersonInfo(name, birthDate, birthTime, location);
    final teaserSection = teaser != null && teaser.isNotEmpty 
        ? '\nTEASER (emotional hook — must be fully resolved in the analysis):\n"$teaser"\n' 
        : '';

    final prompt = '''Provide a PAYWALLED deep-dive psychological analysis of this natal chart placement.

PERSON INFO:
$personInfo
PLACEMENT:
$categoryName: $sign
$teaserSection
ANALYSIS FOCUS:
$categoryDescription

STRICT REQUIREMENTS:
- Write exactly 4 short paragraphs.
- Total length: 150–220 words.
- Treat the TEASER as an unresolved psychological tension — your analysis must clearly explain and unpack it.
- Paragraph 1: The core pattern — what this placement consistently creates in personality and behavior.
- Paragraph 2: The hidden contradiction — where intentions and actions diverge, and why the person often doesn't notice it.
- Paragraph 3: Real-life manifestations — exactly 3 concrete examples (relationships, work, decision-making, stress reactions).
- Paragraph 4: Guidance — exactly 2 concrete actions for the next 7 days (specific, uncomfortable, actionable) + one closing sentence that feels personally addressed.
- Use the person's name naturally 1–2 times (no more).
- Be psychologically sharp and grounded; avoid generic spirituality, clichés, and destiny language.
- Write in $language.
- No greetings, no metaphors, no poetic abstraction.
- Output plain text only.''';

    return _sendMessage(prompt, maxTokens: 500);
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
        'content': '''You are a master astrologer who writes with calm authority and psychological precision.
You must be specific, grounded, and personal — no generic mysticism, no filler, no rambling.

Follow the user's structure requirements exactly.
Output ONLY plain text. No tags, no markdown, no emojis, no bullet symbols beyond normal numbering (1., 2.).
No greetings, no introductions.'''
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





