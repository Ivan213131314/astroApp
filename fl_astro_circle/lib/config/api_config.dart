import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration
/// API ключи загружаются из .env файла
/// Получи ключ на https://openrouter.ai/keys

class ApiConfig {
  ApiConfig._();

  /// OpenRouter API Key (загружается из .env)
  static String get openRouterApiKey => 
      dotenv.env['OPEN_ROUTER_API_KEY'] ?? '';
  
  /// OpenRouter base URL
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  /// Модель для чата (GPT-4o Mini - платная)
  /// Отличное качество, поддержка Vision, высокие лимиты
  /// Стоимость: ~$0.15/1M input, $0.60/1M output
  static const String aiModel = 'openai/gpt-4o-mini-2024-07-18';
  
  /// Модель для Vision (GPT-4o Mini - платная)
  /// Используется для анализа изображений (например, ладони)
  /// Альтернативы: 'google/gemini-2.0-flash-exp:free', 'nvidia/nemotron-nano-12b-v2-v1:free'
  static const String visionModel = 'openai/gpt-4o-mini-2024-07-18';
  
  /// App info для OpenRouter
  static const String appName = 'Astro Circle';
  static const String appUrl = 'https://astrocircle.app';
}








