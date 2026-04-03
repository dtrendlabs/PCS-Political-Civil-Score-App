import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../config/app_secrets.dart';
import '../data/politicians_data.dart';

/// Service that calls OpenAI ChatGPT API to generate detailed
/// candidate profiles as structured JSON.
class OpenAIService {
  OpenAIService._();

  static String? _promptTemplate;
  static final Map<String, Map<String, dynamic>> _cache = {};
  static bool _initialized = false;

  // ─── List of models to try in order of preference ───────────────────
  static const List<String> _modelsToTry = [
    'gpt-4o-mini',
    'gpt-4o',
    'gpt-3.5-turbo',
  ];

  /// Initialize the OpenAI SDK with the API key.
  static void _ensureInitialized() {
    if (!_initialized) {
      OpenAI.apiKey = AppSecrets.openaiApiKey;
      _initialized = true;
    }
  }

  /// Load the prompt template from the .md asset file.
  static Future<String> _loadPromptTemplate() async {
    _promptTemplate ??= await rootBundle
        .loadString('lib/src/prompts/candidate_profile_prompt.md');
    return _promptTemplate!;
  }

  /// Build the full prompt by injecting member details into the template.
  static Future<String> _buildPrompt(LokSabhaMember member) async {
    final template = await _loadPromptTemplate();
    final memberInput = '''

## Candidate to Research

Name: ${member.name}
Party: ${member.party}
Constituency: ${member.constituency}
State: ${member.state}
Date of Birth: ${member.dob}
Lok Sabha Terms: ${member.lokSabhaTerms.join(', ')}
Membership Status: ${member.membershipStatus}

Generate the complete JSON profile for this candidate now.
''';
    return '$template\n$memberInput';
  }

  /// Fetch a detailed candidate profile from OpenAI ChatGPT.
  static Future<Map<String, dynamic>?> fetchCandidateProfile(
      LokSabhaMember member) async {
    _ensureInitialized();

    // Check cache first
    final cacheKey = 'openai_${member.name}_${member.constituency}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    Object? lastError;

    // Try each model until one works or we run out
    for (final modelName in _modelsToTry) {
      try {
        dev.log('Attempting fetch with OpenAI model: $modelName',
            name: 'OPENAI_SERVICE');

        final prompt = await _buildPrompt(member);

        final chatCompletion = await OpenAI.instance.chat.create(
          model: modelName,
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  'You are a political transparency data analyst. '
                  'Return ONLY valid JSON. No markdown, no explanation.',
                ),
              ],
            ),
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
              ],
            ),
          ],
          temperature: 0.4,
          maxTokens: 2048,
        );

        final text = chatCompletion.choices.first.message.content
            ?.firstOrNull
            ?.text;

        if (text == null || text.isEmpty) {
          throw Exception('Empty response from OpenAI model');
        }

        // Strip markdown code fences if present
        String cleanJson = text.trim();
        if (cleanJson.startsWith('```json')) {
          cleanJson = cleanJson.substring(7);
        } else if (cleanJson.startsWith('```')) {
          cleanJson = cleanJson.substring(3);
        }
        if (cleanJson.endsWith('```')) {
          cleanJson = cleanJson.substring(0, cleanJson.length - 3);
        }
        cleanJson = cleanJson.trim();

        // Parse and return on success
        final jsonData = json.decode(cleanJson) as Map<String, dynamic>;
        _cache[cacheKey] = jsonData;

        dev.log('Successfully used OpenAI model: $modelName',
            name: 'OPENAI_SERVICE');

        return jsonData;
      } catch (e) {
        lastError = e;
        final errorMsg = e.toString().toLowerCase();
        dev.log('OpenAI model $modelName failed: $errorMsg',
            name: 'OPENAI_SERVICE');

        // Retryable errors — try the next model
        final isRetryable = errorMsg.contains('not found') ||
            errorMsg.contains('404') ||
            errorMsg.contains('500') ||
            errorMsg.contains('503') ||
            errorMsg.contains('504') ||
            errorMsg.contains('unavailable') ||
            errorMsg.contains('overloaded') ||
            errorMsg.contains('model_not_found');

        if (isRetryable) {
          dev.log(
              'OpenAI model $modelName is unavailable. Trying next model...',
              name: 'OPENAI_SERVICE');
          continue;
        }

        // For other errors (rate limit 429, auth 401), stop and report to UI
        rethrow;
      }
    }

    // If we're here, all models failed
    if (lastError != null) {
      throw lastError;
    }
    return null;
  }

  /// Clear the in-memory cache.
  static void clearCache() {
    _cache.clear();
  }
}
