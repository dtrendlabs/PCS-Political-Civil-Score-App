import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CivilScoreScreen extends StatefulWidget {
  const CivilScoreScreen({super.key});

  @override
  State<CivilScoreScreen> createState() => _CivilScoreScreenState();
}

class _CivilScoreScreenState extends State<CivilScoreScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _politicians = [
    {
      'name': 'Sen. Maria Chen',
      'role': 'Senator',
      'district': 'District 2',
      'score': 92,
      'trend': 'up',
      'trendValue': '+3.2',
      'image':
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100&h=100&fit=crop&crop=face',
    },
    {
      'name': 'Gov. James Obi',
      'role': 'Governor',
      'district': 'State Capital',
      'score': 88,
      'trend': 'up',
      'trendValue': '+1.8',
      'image':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop&crop=face',
    },
    {
      'name': 'Rep. Aisha Patel',
      'role': 'Representative',
      'district': 'District 7',
      'score': 85,
      'trend': 'up',
      'trendValue': '+2.1',
      'image':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face',
    },
    {
      'name': 'Sen. Robert Lamar',
      'role': 'Senator',
      'district': 'District 9',
      'score': 79,
      'trend': 'down',
      'trendValue': '-1.4',
      'image':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
    },
    {
      'name': 'Rep. Elena Vasquez',
      'role': 'Representative',
      'district': 'District 3',
      'score': 76,
      'trend': 'up',
      'trendValue': '+0.8',
      'image':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
    },
    {
      'name': 'Gov. Sarah Mitchell',
      'role': 'Governor',
      'district': 'West Province',
      'score': 73,
      'trend': 'stable',
      'trendValue': '0.0',
      'image':
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=100&h=100&fit=crop&crop=face',
    },
    {
      'name': 'Sen. Alistair Vance',
      'role': 'Senator',
      'district': 'District 4',
      'score': 68,
      'trend': 'down',
      'trendValue': '-2.5',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
    },
    {
      'name': 'Rep. David Nakamura',
      'role': 'Representative',
      'district': 'District 12',
      'score': 64,
      'trend': 'down',
      'trendValue': '-3.1',
      'image':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
    },
    {
      'name': 'Gov. Patricia Wong',
      'role': 'Governor',
      'district': 'East Province',
      'score': 58,
      'trend': 'down',
      'trendValue': '-4.7',
      'image':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop&crop=face',
    },
    {
      'name': 'Sen. Marcus Oduya',
      'role': 'Senator',
      'district': 'District 1',
      'score': 51,
      'trend': 'down',
      'trendValue': '-5.2',
      'image':
          'https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=100&h=100&fit=crop&crop=face',
    },
  ];

  List<Map<String, dynamic>> get _filteredPoliticians {
    var list = _politicians;
    if (_selectedFilter != 'All') {
      list = list
          .where((p) => (p['role'] as String) == _filterToRole(_selectedFilter))
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) => (p['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  String _filterToRole(String filter) {
    switch (filter) {
      case 'Senators':
        return 'Senator';
      case 'Representatives':
        return 'Representative';
      case 'Governors':
        return 'Governor';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildFilterChips(),
        const SizedBox(height: 8),
        Expanded(
          child: _buildPoliticianList(),
        ),
      ],
    );
  }

  // ─── Header with Search ──────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B2A4A),
            Color(0xFF2C3E6B),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Civil Score Rankings',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Transparency scores for elected officials',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 18),
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(40)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Search politicians...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white38,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.white54, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.white54, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Filter Chips ────────────────────────────────────────────────
  Widget _buildFilterChips() {
    final filters = ['All', 'Senators', 'Representatives', 'Governors'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = _selectedFilter == filters[index];
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filters[index]);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1B2A4A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1B2A4A)
                        : const Color(0xFFE0E4EA),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color.fromRGBO(27, 42, 74, 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filters[index],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF4A5568),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Politician List ─────────────────────────────────────────────
  Widget _buildPoliticianList() {
    final list = _filteredPoliticians;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No officials found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final p = list[index];
        final score = p['score'] as int;
        final trend = p['trend'] as String;
        final trendValue = p['trendValue'] as String;

        Color scoreColor;
        if (score >= 80) {
          scoreColor = const Color(0xFF2ECC71);
        } else if (score >= 60) {
          scoreColor = const Color(0xFFE67E22);
        } else {
          scoreColor = const Color(0xFFE74C3C);
        }

        IconData trendIcon;
        Color trendColor;
        if (trend == 'up') {
          trendIcon = Icons.trending_up;
          trendColor = const Color(0xFF2ECC71);
        } else if (trend == 'down') {
          trendIcon = Icons.trending_down;
          trendColor = const Color(0xFFE74C3C);
        } else {
          trendIcon = Icons.trending_flat;
          trendColor = const Color(0xFF7A8BA5);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 28,
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: index < 3
                        ? const Color(0xFF1B2A4A)
                        : const Color(0xFF7A8BA5),
                  ),
                ),
              ),
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF3A4F6F),
                backgroundImage: NetworkImage(p['image'] as String),
              ),
              const SizedBox(width: 14),
              // Name & district
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B2A4A),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          p['district'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF7A8BA5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(trendIcon, color: trendColor, size: 14),
                        Text(
                          trendValue,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Score
              CircularPercentIndicator(
                radius: 24,
                lineWidth: 4.5,
                percent: score / 100,
                center: Text(
                  '$score',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
                progressColor: scoreColor,
                backgroundColor: const Color(0xFFE8ECF0),
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
        );
      },
    );
  }
}
