import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fl_astro_circle/config/api_config.dart';

/// Результат анализа ладони
class PalmReadingResult {
  final String lifeLine;
  final String heartLine;
  final String moneyLine;
  final String healthLine;
  final String? imageBase64;

  PalmReadingResult({
    required this.lifeLine,
    required this.heartLine,
    required this.moneyLine,
    required this.healthLine,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() => {
    'lifeLine': lifeLine,
    'heartLine': heartLine,
    'moneyLine': moneyLine,
    'healthLine': healthLine,
    'imageBase64': imageBase64,
  };

  factory PalmReadingResult.fromJson(Map<String, dynamic> json) {
    return PalmReadingResult(
      lifeLine: json['lifeLine'] ?? '',
      heartLine: json['heartLine'] ?? '',
      moneyLine: json['moneyLine'] ?? '',
      healthLine: json['healthLine'] ?? '',
      imageBase64: json['imageBase64'],
    );
  }
}

/// Сервис для анализа ладони с помощью AI Vision
class PalmReadingService {
  final String _apiKey;
  final String _baseUrl;
  final String _model;

  PalmReadingService({
    String? apiKey,
    String? baseUrl,
    String? model,
  })  : _apiKey = apiKey ?? ApiConfig.openRouterApiKey,
        _baseUrl = baseUrl ?? ApiConfig.openRouterBaseUrl,
        _model = model ?? ApiConfig.visionModel;

  /// Анализ фото ладони
  Future<PalmReadingResult> analyzePalm({
    required File imageFile,
    String language = 'Russian',
  }) async {
    try {
      // Конвертация изображения в base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final imageUrl = 'data:image/jpeg;base64,$base64Image';

      // Промпт для AI
      final prompt = '''Analyze this photo. First, determine if it shows a human palm/hand suitable for palmistry reading.

IMPORTANT: Respond with ONLY a valid JSON object, no additional text or formatting.

If this is NOT a clear photo of a palm/hand, set "isValidPalmPhoto" to false.
If this IS a photo of a palm/hand, analyze these four main lines:
1. Life Line - longevity, vitality, life path
2. Heart Line - emotions, relationships, love
3. Money Line - wealth, career success, financial luck  
4. Health Line - physical and mental wellbeing

FORMAT YOUR RESPONSE EXACTLY LIKE THIS (valid JSON only):
{
  "isValidPalmPhoto": true or false,
  "lifeLine": "Detailed analysis of life line in $language (3-4 sentences)" or "Not applicable",
  "heartLine": "Detailed analysis of heart line in $language (3-4 sentences)" or "Not applicable",
  "moneyLine": "Detailed analysis of money line in $language (3-4 sentences)" or "Not applicable",
  "healthLine": "Detailed analysis of health line in $language (3-4 sentences)" or "Not applicable"
}

If isValidPalmPhoto is false, set all line readings to "Not applicable".
DO NOT include any text before or after the JSON. ONLY output valid JSON.''';

      // Формируем запрос с vision support
      final messages = [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {'type': 'image_url', 'image_url': {'url': imageUrl}},
          ],
        },
      ];

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
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        
        if (content == null) {
          throw PalmReadingException('Empty response from AI');
        }

        // Парсим JSON ответ
        final cleanedContent = _cleanJsonResponse(content as String);
        final resultJson = jsonDecode(cleanedContent) as Map<String, dynamic>;

        return PalmReadingResult(
          lifeLine: resultJson['lifeLine'] ?? 'Unable to analyze life line',
          heartLine: resultJson['heartLine'] ?? 'Unable to analyze heart line',
          moneyLine: resultJson['moneyLine'] ?? 'Unable to analyze money line',
          healthLine: resultJson['healthLine'] ?? 'Unable to analyze health line',
          imageBase64: base64Image,
        );
      } else if (response.statusCode == 401) {
        throw PalmReadingException('Invalid API key');
      } else if (response.statusCode == 429) {
        throw PalmReadingException('Rate limit exceeded. Please try again later.');
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
        throw PalmReadingException('API error (${response.statusCode}): $errorMessage');
      }
    } on SocketException {
      throw PalmReadingException('No internet connection');
    } on http.ClientException catch (e) {
      throw PalmReadingException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw PalmReadingException('Invalid response format: ${e.message}');
    }
  }

  /// Очистка JSON ответа от лишнего текста
  String _cleanJsonResponse(String response) {
    // Удаляем markdown код блоки если есть
    String cleaned = response.replaceAll(RegExp(r'```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');
    
    // Убираем специальные токены LLM
    final patterns = [
      RegExp(r'\[BOS\]', caseSensitive: false),
      RegExp(r'\[EOS\]', caseSensitive: false),
      RegExp(r'<bot>', caseSensitive: false),
      RegExp(r'</bot>', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      cleaned = cleaned.replaceAll(pattern, '');
    }
    
    cleaned = cleaned.trim();
    
    // Находим JSON объект в тексте (на случай если есть лишний текст)
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (jsonMatch != null) {
      return jsonMatch.group(0)!;
    }
    
    return cleaned;
  }
}

/// Исключение для ошибок анализа ладони
class PalmReadingException implements Exception {
  final String message;

  PalmReadingException(this.message);

  @override
  String toString() => message;
}
