/// API Configuration
/// ВАЖНО: Замени API ключ на свой!
/// Получи ключ на https://openrouter.ai/keys

class ApiConfig {
  ApiConfig._();

  /// OpenRouter API Key
  /// Бесплатные модели не требуют оплаты, но нужен аккаунт
  static const String openRouterApiKey = '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';
  
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







