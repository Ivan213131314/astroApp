import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_astro_circle/config/api_config.dart';

/// Контекст для AI чата - определяет системный промпт
enum AiChatContext {
  astrologerChat,  // Общение с астрологом
  compatibility,   // Генерация совместимости
  natalChart,      // Интерпретация натальной карты
}

/// Категории совместимости
enum CompatibilityCategory {
  love,      // Love & Passion
  business,  // Business & Career
  health,    // Health & Wellness
}

/// Сервис для работы с AI через OpenRouter
class AiChatService {
  final String _apiKey;
  final String _baseUrl;
  final String _model;
  
  AiChatService({
    String? apiKey,
    String? baseUrl,
    String? model,
  }) : _apiKey = apiKey ?? ApiConfig.openRouterApiKey,
       _baseUrl = baseUrl ?? ApiConfig.openRouterBaseUrl,
       _model = model ?? ApiConfig.aiModel;

  /// Получить системный промпт для контекста
  String _getSystemPrompt(AiChatContext context, {Map<String, dynamic>? userData}) {
    switch (context) {
      case AiChatContext.astrologerChat:
        return '''You are Astro Maya, a mystical and wise astrologer with years of experience reading the stars.
You speak with warmth, wisdom, and a touch of cosmic mystery.
You naturally reference celestial bodies, planetary alignments, zodiac signs, and cosmic energies.
Keep your responses concise (2-4 sentences) but deeply insightful and meaningful.
Never break character - you ARE a real astrologer named Astro Maya.
Always respond in the same language the user writes to you.
Add subtle mystical touches to your speech like "The stars reveal..." or "I sense in your aura..."''';
      
      case AiChatContext.compatibility:
        final sign1 = userData?['sign1'] ?? 'unknown';
        final sign2 = userData?['sign2'] ?? 'unknown';
        return '''You are an expert astrologer providing detailed compatibility analysis between $sign1 and $sign2.
Provide a comprehensive but engaging analysis covering:
- Emotional and spiritual compatibility
- Communication styles and how they mesh
- Key strengths of this cosmic pairing  
- Potential challenges and how to overcome them
- Love and romance compatibility
- Overall harmony rating (as a percentage)

Write in a warm, mystical yet professional tone.
Always respond in the same language the user writes to you.
Make the reading feel personal and insightful.''';
      
      case AiChatContext.natalChart:
        return '''You are an expert astrologer interpreting natal birth charts.
Given planetary positions, provide deep analysis of:
- Sun sign influence (core identity and life purpose)
- Moon sign (emotional nature and inner world)
- Rising/Ascendant sign (outer personality and first impressions)
- Key planetary aspects and their profound meanings
- Life path insights based on the celestial configuration

Write poetically but informatively, making complex astrological concepts accessible.
Always respond in the same language the user writes to you.
Make each reading feel uniquely personal and transformative.''';
    }
  }

  /// Отправить сообщение и получить ответ от AI
  Future<String> sendMessage({
    required String userMessage,
    required AiChatContext context,
    List<Map<String, String>>? conversationHistory,
    Map<String, dynamic>? userData,
  }) async {
    // Формируем список сообщений
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _getSystemPrompt(context, userData: userData)},
    ];
    
    // Добавляем историю переписки для контекста
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      // Ограничиваем историю последними 10 сообщениями для экономии токенов
      final recentHistory = conversationHistory.length > 10 
          ? conversationHistory.sublist(conversationHistory.length - 10)
          : conversationHistory;
      messages.addAll(recentHistory);
    }
    
    // Добавляем текущее сообщение пользователя
    messages.add({'role': 'user', 'content': userMessage});

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
          'max_tokens': 500,
          'temperature': 0.8, // Более креативные ответы для астрологии
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null) {
          return _cleanAiResponse(content as String);
        }
        throw AiChatException('Empty response from AI');
      } else if (response.statusCode == 401) {
        throw AiChatException('Invalid API key. Please check your OpenRouter API key.');
      } else if (response.statusCode == 429) {
        throw AiChatException('Rate limit exceeded. Please try again later.');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw AiChatException('OpenRouter error (${response.statusCode}): $errorMessage');
      }
    } on http.ClientException catch (e) {
      throw AiChatException('Network error: ${e.message}');
    } on FormatException {
      throw AiChatException('Invalid response format from server');
    }
  }
  
  /// Генерация анализа совместимости знаков
  Future<String> generateCompatibility({
    required String sign1,
    required String sign2,
    String? birthDate1,
    String? birthDate2,
    String? language,
  }) async {
    final lang = language ?? 'English';
    final prompt = '''Please analyze the astrological compatibility between:
Person 1: $sign1${birthDate1 != null ? ' (born $birthDate1)' : ''}
Person 2: $sign2${birthDate2 != null ? ' (born $birthDate2)' : ''}

Provide a comprehensive and insightful compatibility reading in $lang.''';

    return sendMessage(
      userMessage: prompt,
      context: AiChatContext.compatibility,
      userData: {'sign1': sign1, 'sign2': sign2},
    );
  }
  
  /// Интерпретация натальной карты
  Future<String> interpretNatalChart({
    required String sunSign,
    required String moonSign,
    required String ascendant,
    Map<String, String>? planetaryPositions,
    String? language,
  }) async {
    final lang = language ?? 'English';
    final planetsInfo = planetaryPositions != null && planetaryPositions.isNotEmpty
        ? '\n\nPlanetary positions:\n${planetaryPositions.entries.map((e) => '${e.key}: ${e.value}').join('\n')}'
        : '';
    
    final prompt = '''Please interpret this natal chart in $lang:

Sun Sign: $sunSign
Moon Sign: $moonSign  
Ascendant/Rising: $ascendant$planetsInfo

Provide an insightful and transformative reading of this person's astrological profile.''';

    return sendMessage(
      userMessage: prompt,
      context: AiChatContext.natalChart,
    );
  }

  /// Генерация тизера совместимости (короткий интригующий текст 1-2 абзаца)
  Future<String> generateCompatibilityTeaser({
    required String sign1,
    required String sign2,
    required CompatibilityCategory category,
    required String language,
    String? name1,
    String? name2,
    String? birthDate1,
    String? birthDate2,
  }) async {
    final categoryName = _getCategoryName(category);
    
    // Формируем информацию о людях
    final person1Info = _formatPersonInfo(name1, sign1, birthDate1);
    final person2Info = _formatPersonInfo(name2, sign2, birthDate2);
    
    final prompt = '''Generate a VERY SHORT, emotionally charged compatibility teaser for $categoryName.

PERSONS:
- Person 1: $person1Info
- Person 2: $person2Info

STRICT REQUIREMENTS:
- Write EXACTLY 1–2 short sentences (no more).
- Use very simple, everyday language.
- Use their names naturally (if provided).
- Do NOT explain reasons or dynamics.
- Write in $language
- Do NOT mention zodiac mechanics or astrology terms.
- Focus on tension, risk, or something unsettling beneath the surface.
- The text must feel unfinished, like something important is being withheld.
- Prefer questions or ominous statements.
- Make it slightly alarming or uncomfortable.
- End with uncertainty or a question.
- No greetings.
- No metaphors.
- No long descriptions.

OUTPUT:
Pure text only. No formatting. No emojis. No symbols.''';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': 'You are a mystical astrologer. Output ONLY the requested text, no tags, no markers, no special characters. Never use [BOS], [EOS], <bot>, </bot> or similar tokens.'},
      {'role': 'user', 'content': prompt},
    ];

    return _sendRawMessage(messages, maxTokens: 250);
  }

  /// Генерация детального анализа совместимости (4 абзаца, 160-230 слов)
  Future<String> generateCompatibilityDetail({
    required String sign1,
    required String sign2,
    required CompatibilityCategory category,
    required String language,
    required String teaser,
    String? name1,
    String? name2,
    String? birthDate1,
    String? birthDate2,
  }) async {
    final categoryName = _getCategoryName(category);
    
    // Формируем информацию о людях
    final person1Info = _formatPersonInfo(name1, sign1, birthDate1);
    final person2Info = _formatPersonInfo(name2, sign2, birthDate2);
    
    final prompt = '''Write a paid, in-depth compatibility reading for $categoryName.

PERSONS:
- Person 1: $person1Info
- Person 2: $person2Info

TEASER (use this as the emotional trigger):
"$teaser"

STRICT REQUIREMENTS:
- Write EXACTLY 4 short paragraphs.
- Total length: 160–230 words.
- Use very simple, everyday language.
- No metaphors, no spiritual lectures, no astrology terms.
- Use their names naturally 1–2 times total (if provided).
- Be emotionally sharp and slightly alarming at first.
- Make the reader feel tension, doubt, or risk in the beginning.
- Resolve the tension by the end, offering calm and clarity.
- Everything must feel realistic and psychological, not mystical.

PARAGRAPH STRUCTURE:
1) Amplify the anxiety from the teaser.
   Make it feel like something is wrong, fragile, or risky.
   Create the sense that this connection could quietly fall apart.

2) Name the core problem.
   One clear issue, flaw, or pattern that creates this tension.
   Keep it blunt and uncomfortable.

3) Reframe.
   Explain that this problem is common and manageable.
   Reduce fear. Show that it does NOT mean disaster.

4) Calm resolution.
   Explain that things can be stable and safe IF a specific condition is met.
   End with reassurance, control, and a grounded takeaway.

ENDING RULE:
- The final sentence must contain a conditional reassurance:
  "Everything will be fine if..."
  "This works only when..."
  "Nothing breaks unless..."

Write in $language.
Output plain text only.
No emojis.
No formatting.
No headings.''';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': 'You are an astrologer speaking in a simple, direct, emotionally engaging way. Output ONLY the requested analysis, no tags, no markers, no special characters. Never use [BOS], [EOS], <bot>, </bot> or similar tokens. Write naturally and personally.'},
      {'role': 'user', 'content': prompt},
    ];

    return _sendRawMessage(messages, maxTokens: 800);
  }


  String _formatPersonInfo(String? name, String sign, String? birthDate) {
    final parts = <String>[];
    if (name != null && name.isNotEmpty) {
      parts.add(name);
    }
    parts.add(sign);
    if (birthDate != null && birthDate.isNotEmpty) {
      parts.add('born $birthDate');
    }
    return parts.join(', ');
  }

  String _getCategoryName(CompatibilityCategory category) {
    switch (category) {
      case CompatibilityCategory.love:
        return 'Love & Passion';
      case CompatibilityCategory.business:
        return 'Business & Career';
      case CompatibilityCategory.health:
        return 'Health & Wellness';
    }
  }

  String _getCategoryDetailPrompt(CompatibilityCategory category) {
    switch (category) {
      case CompatibilityCategory.love:
        return '''Focus on:
- Emotional connection and depth of feelings
- Romantic chemistry and physical attraction
- Communication in intimate relationships
- Long-term relationship potential
- How Venus and Mars placements affect the union
- Passion dynamics and maintaining the spark
- Challenges in love and how to overcome them
- Soul connection and spiritual bond''';
      
      case CompatibilityCategory.business:
        return '''Focus on:
- Professional collaboration dynamics
- Communication styles in work settings
- Leadership and decision-making compatibility
- Financial attitudes and money management together
- How Mercury and Saturn influence the partnership
- Strengths each sign brings to business ventures
- Potential conflicts and how to resolve them
- Long-term business success potential''';
      
      case CompatibilityCategory.health:
        return '''Focus on:
- How the signs influence each other's wellbeing
- Stress management and emotional support
- Lifestyle compatibility and daily habits
- How the Moon affects emotional health together
- Physical activity and wellness approaches
- Mental health support dynamics
- Healing energies between the signs
- Creating a healthy, balanced life together''';
    }
  }

  /// Генерация ответа от вселенной (Universe Sign)
  /// Создает мистическое персонализированное сообщение на основе категории и вопроса
  Future<String> generateUniverseSign({
    required String question,
    required String category,
    String language = 'English',
  }) async {
    final categoryInfo = _getUniverseSignCategoryInfo(category);
    
    // Получаем текущую дату
    final now = DateTime.now();
    final todayDate = '${now.day}.${now.month}.${now.year}';
    
    final prompt = '''Deliver a clear cosmic sign for TODAY.

CATEGORY: ${categoryInfo['name']}
USER QUESTION: "$question"

TEXT REQUIREMENTS:
– Total length: 100–180 words
– Easy to read on mobile
– Short paragraphs with spacing
– Calm, intimate tone
– No dates, no explanations, no headers

STRUCTURE:

1) Recognition (2–3 sentences)
Acknowledge the user's current inner state, doubt, or tension related to their question.
Name it gently and clearly.

2) The Sign (1 short paragraph)
Give ONE main message for today.
Focus on direction, not destiny.
It must feel applicable within the next 24 hours.

3) Signs to notice today:
Provide exactly 2 concrete, realistic signs.
Use a numbered list.
They must be observable in daily life (thoughts, conversations, pauses, emotions).

4) Closing (2–3 sentences)
Offer reassurance or permission.
Help the user emotionally close the day, not open infinite possibilities.

5) End with 3 indicators:
🌟 Alignment Today: XX%
💗 Emotional Clarity: XX%
🔮 Intuitive Signal: XX%

STYLE RULES:
– Write in $language
– Be mystical, but restrained
– Be human, not abstract
– This is a sign, not a sermon
– Start immediately with the message''';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': '''You are the Voice of the Universe.

You do not preach, you do not motivate, and you do not write long spiritual essays.
You deliver a calm, grounded sign for TODAY.

Your message must:
– acknowledge the user's inner tension or question
– offer one clear direction for this day
– feel personal, human, and reassuring
– sound like guidance, not poetry

Avoid vague spirituality, clichés, and excessive metaphors.
Keep the message emotionally precise and concise.

Output only the final text.'''},
      {'role': 'user', 'content': prompt},
    ];

    return _sendRawMessage(messages, maxTokens: 800);
  }

  /// Информация о категориях для Universe Sign
  Map<String, String> _getUniverseSignCategoryInfo(String category) {
    switch (category) {
      case 'love':
        return {
          'name': 'Love',
          'emoji': '❤️',
          'focus': '''Focus on matters of the heart:
- Romantic connections and soulmate energy
- Emotional healing and self-love
- Relationship dynamics and transformations
- Venus and Moon influences on love''',
        };
      case 'money':
        return {
          'name': 'Money & Abundance',
          'emoji': '💰',
          'focus': '''Focus on prosperity and abundance:
- Financial opportunities approaching
- Career growth and professional paths
- Abundance mindset and manifestation
- Jupiter and Saturn influences on wealth''',
        };
      case 'path':
        return {
          'name': 'Life Path',
          'emoji': '🌿',
          'focus': '''Focus on life direction and purpose:
- Soul mission and life purpose
- Important decisions and crossroads
- Personal growth and spiritual evolution
- North Node and destiny influences''',
        };
      case 'decision':
        return {
          'name': 'Decision',
          'emoji': '🔮',
          'focus': '''Focus on choices and clarity:
- Guidance for important decisions
- Trusting intuition and inner wisdom
- Timing and cosmic alignment for action
- Mercury and Uranus influences on clarity''',
        };
      default:
        return {
          'name': 'Cosmic Guidance',
          'emoji': '✨',
          'focus': 'General cosmic wisdom and universal guidance.',
        };
    }
  }

  /// Отправка сообщений напрямую (без системного промпта из контекста)
  Future<String> _sendRawMessage(List<Map<String, String>> messages, {int maxTokens = 500}) async {
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
        throw AiChatException('Empty response from AI');
      } else if (response.statusCode == 401) {
        throw AiChatException('Invalid API key. Please check your OpenRouter API key.');
      } else if (response.statusCode == 429) {
        throw AiChatException('Rate limit exceeded. Please try again later.');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw AiChatException('OpenRouter error (${response.statusCode}): $errorMessage');
      }
    } on http.ClientException catch (e) {
      throw AiChatException('Network error: ${e.message}');
    } on FormatException {
      throw AiChatException('Invalid response format from server');
    }
  }

  /// Очистка ответа AI от специальных токенов LLM
  String _cleanAiResponse(String response) {
    // Список паттернов для удаления (специальные токены LLM)
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

    // Удаляем лишние пробелы и переносы строк в начале и конце
    cleaned = cleaned.trim();
    
    // Заменяем множественные переносы строк на двойной
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    return cleaned;
  }
}

/// Исключение для ошибок AI чата
class AiChatException implements Exception {
  final String message;
  
  AiChatException(this.message);
  
  @override
  String toString() => message;
}
