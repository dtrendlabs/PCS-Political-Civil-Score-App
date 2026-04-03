import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_secrets.dart';
import '../data/politicians_data.dart';

/// Service that calls Google Gemini API to generate detailed
/// candidate profiles as structured JSON.
class GeminiService {
  GeminiService._();

  static String? _promptTemplate;
  static final Map<String, Map<String, dynamic>> _cache = {};

  // ─── List of models to try in order of preference ───────────────────
  static const List<String> _modelsToTry = [
    'gemini-3-flash-preview',
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-pro-1.5',
    'gemini-pro',
  ];

  /// Initialize the Gemini model for a specific model ID.
  static GenerativeModel _createModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: AppSecrets.googleGeminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topP: 0.95,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
      ),
    );
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

  /// Fetch a detailed candidate profile from Gemini.
  static Future<Map<String, dynamic>?> fetchCandidateProfile(
      LokSabhaMember member) async {
    // Check cache first
    final cacheKey = '${member.name}_${member.constituency}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    Object? lastError;

    // Try each model until one works or we run out
    for (final modelName in _modelsToTry) {
      try {
        dev.log('Attempting fetch with model: $modelName', name: 'GEMINI_SERVICE');
        
        final model = _createModel(modelName);
        final prompt = await _buildPrompt(member);

        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text;

        if (text == null || text.isEmpty) {
          throw Exception('Empty response from model');
        }

        // Parse and return on success
        final jsonData = json.decode(text) as Map<String, dynamic>;
        _cache[cacheKey] = jsonData;
        
        dev.log('Successfully used model: $modelName', name: 'GEMINI_SERVICE');
        
        return jsonData;
      } catch (e) {
        lastError = e;
        // Log the failure
        final errorMsg = e.toString().toLowerCase();
        dev.log('Model $modelName failed: $errorMsg', name: 'GEMINI_SERVICE');

        // Fallback for: 404, 500, 503, 504, "unavailable", "not found", "limit reached"
        // Basically anything that isn't a 400 Bad Request (which is usually a prompt/config issue)
        final isRetryable = errorMsg.contains('not found') || 
                           errorMsg.contains('404') || 
                           errorMsg.contains('500') ||
                           errorMsg.contains('503') ||
                           errorMsg.contains('504') ||
                           errorMsg.contains('unavailable') ||
                           errorMsg.contains('overloaded') ||
                           errorMsg.contains('quota') ||
                           errorMsg.contains('429');

        if (isRetryable) {
          dev.log('Model $modelName is unavailable or limited. Trying next model...', name: 'GEMINI_SERVICE');
          continue;
        }
        
        // For other errors (like 429 quota), stop and report to UI
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
