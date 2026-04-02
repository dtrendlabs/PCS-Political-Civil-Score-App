import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_secrets.dart';
import '../data/politicians_data.dart';

/// Service that calls Google Gemini API to generate detailed
/// candidate profiles as structured JSON.
class GeminiService {
  GeminiService._();

  static GenerativeModel? _model;
  static String? _promptTemplate;

  // ─── Cache for already-fetched profiles ─────────────────────────
  static final Map<String, Map<String, dynamic>> _cache = {};

  /// Initialize the Gemini model (lazy, called once).
  static GenerativeModel _getModel() {
    _model ??= GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: AppSecrets.googleGeminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topP: 0.95,
        maxOutputTokens: 4096,
        responseMimeType: 'application/json',
      ),
    );
    return _model!;
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
  ///
  /// Returns a parsed `Map<String, dynamic>` matching the JSON schema
  /// defined in the prompt template, or `null` if the call fails.
  static Future<Map<String, dynamic>?> fetchCandidateProfile(
      LokSabhaMember member) async {
    // Check cache first
    final cacheKey = '${member.name}_${member.constituency}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final model = _getModel();
      final prompt = await _buildPrompt(member);

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.isEmpty) {
        return null;
      }

      // Parse the JSON response
      final jsonData = json.decode(text) as Map<String, dynamic>;

      // Cache it
      _cache[cacheKey] = jsonData;

      return jsonData;
    } catch (e) {
      // Log failure for debugging — never log API keys!
      // ignore: avoid_print
      print('Gemini API error: $e');
      return null;
    }
  }

  /// Clear the in-memory cache.
  static void clearCache() {
    _cache.clear();
  }
}
