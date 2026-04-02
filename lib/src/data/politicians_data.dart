import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Lok Sabha member model — parsed from lok_sabha_members.json
class LokSabhaMember {
  final String imageUrl;
  final String name;
  final String party;
  final String constituency;
  final String state;
  final String membershipStatus;
  final List<String> lokSabhaTerms;
  final String dob;
  final String presentAddress;
  final String permanentAddress;

  const LokSabhaMember({
    required this.imageUrl,
    required this.name,
    required this.party,
    required this.constituency,
    required this.state,
    required this.membershipStatus,
    required this.lokSabhaTerms,
    required this.dob,
    required this.presentAddress,
    required this.permanentAddress,
  });

  factory LokSabhaMember.fromJson(Map<String, dynamic> json) {
    return LokSabhaMember(
      imageUrl: json['image_url'] as String? ?? '',
      name: json['name'] as String? ?? '',
      party: json['party'] as String? ?? '',
      constituency: json['constituency'] as String? ?? '',
      state: json['state'] as String? ?? '',
      membershipStatus: json['membership_status'] as String? ?? '',
      lokSabhaTerms: (json['lok_sabha_terms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dob: json['dob'] as String? ?? '',
      presentAddress: json['present_address'] as String? ?? '',
      permanentAddress: json['permanent_address'] as String? ?? '',
    );
  }

  /// Check if member matches a search query (name, party, constituency, state)
  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        party.toLowerCase().contains(q) ||
        constituency.toLowerCase().contains(q) ||
        state.toLowerCase().contains(q);
  }

  /// Number of Lok Sabha terms served
  int get termCount => lokSabhaTerms.length;

  /// Whether this is a currently sitting member
  bool get isSitting => membershipStatus == 'SITTING';
}

/// Service to load and cache member data from the bundled JSON asset.
class MemberDataService {
  static List<LokSabhaMember>? _cachedMembers;

  /// Load all Lok Sabha members from the bundled JSON asset.
  /// Results are cached after the first call.
  static Future<List<LokSabhaMember>> loadMembers() async {
    if (_cachedMembers != null) return _cachedMembers!;

    final jsonString =
        await rootBundle.loadString('lib/src/lok_sabha_members.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    _cachedMembers = jsonList
        .map((e) => LokSabhaMember.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cachedMembers!;
  }

  /// Get unique party names from all members.
  static Future<List<String>> getParties() async {
    final members = await loadMembers();
    final parties = members.map((m) => m.party).toSet().toList()..sort();
    return parties;
  }

  /// Get unique states from all members.
  static Future<List<String>> getStates() async {
    final members = await loadMembers();
    final states = members.map((m) => m.state).toSet().toList()..sort();
    return states;
  }
}
