import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Minimal Z.ai client for GLM 4.7 via coding endpoint.
///
/// Usage:
/// ```dart
/// final client = ZaiClient();
/// final result = await client.chat(
///   messages: const [
///     {"role": "user", "content": "Hello"},
///   ],
/// );
/// print(result["choices"][0]["message"]["content"]);
/// ```
///
/// API key resolution order:
/// - Constructor param [apiKey]
/// - Dart define: --dart-define=ZAI_API_KEY=...
///
/// Coding endpoint is required when using the GLM Coding plan.
class ZaiClient {
  // Coding endpoint documented at https://docs.z.ai/guides/develop/http/introduction
  static const String defaultEndpoint =
      'https://api.z.ai/api/coding/paas/v4/chat/completions';

  // General endpoint (not used by default):
  static const String generalEndpoint =
      'https://api.z.ai/api/paas/v4/chat/completions';

  final String apiKey;
  final String endpoint;
  final Duration timeout;

  ZaiClient({
    String? apiKey,
    this.endpoint = defaultEndpoint,
    this.timeout = const Duration(seconds: 30),
  }) : apiKey = apiKey ?? const String.fromEnvironment('ZAI_API_KEY') {
    if (this.apiKey.isEmpty) {
      throw StateError(
        'ZAI_API_KEY is missing. Pass apiKey or --dart-define=ZAI_API_KEY=...',
      );
    }
  }

  /// Sends a chat completion request.
  /// [messages] must be a list of maps with keys: role (system|user|assistant) and content.
  /// Streaming is not implemented here; set [stream] only if false.
  Future<Map<String, dynamic>> chat({
    required List<Map<String, String>> messages,
    String model = 'glm-4.7',
    double? temperature,
    int? maxTokens,
    bool stream = false,
  }) async {
    if (stream) {
      throw UnsupportedError('stream=true is not implemented in this helper');
    }

    final uri = Uri.parse(endpoint);
    final body = <String, dynamic>{'model': model, 'messages': messages};

    if (temperature != null) body['temperature'] = temperature;
    if (maxTokens != null) body['max_tokens'] = maxTokens;
    if (stream) body['stream'] = true; // future-proof

    final response = await http
        .post(
          uri,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $apiKey',
            HttpHeaders.contentTypeHeader: 'application/json',
            'Accept-Language': 'en-US,en',
          },
          body: jsonEncode(body),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw HttpException(
        'Z.ai error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
