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
  
  /// Модель для чата (бесплатная Mistral 7B)
  /// Альтернативы: 'google/gemma-7b-it:free', 'meta-llama/llama-3-8b-instruct:free'
  static const String aiModel = 'mistralai/mistral-7b-instruct:free';
  
  /// App info для OpenRouter
  static const String appName = 'Astro Circle';
  static const String appUrl = 'https://astrocircle.app';
}



