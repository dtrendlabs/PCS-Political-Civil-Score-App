import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../src/data/politicians_data.dart';
import 'member_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedState = 'All States';
  String _selectedParty = 'All Parties';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  List<LokSabhaMember> _allMembers = [];
  List<String> _states = [];
  List<String> _parties = [];
  bool _isLoading = true;

  final List<String> _recentSearches = [
    'BJP',
    'Tamil Nadu',
    'INC',
    'Modi',
  ];

  List<LokSabhaMember> get _filteredMembers {
    var list = _allMembers;

    // State filter
    if (_selectedState != 'All States') {
      list = list.where((m) => m.state == _selectedState).toList();
    }

    // Party filter
    if (_selectedParty != 'All Parties') {
      list = list.where((m) => m.party == _selectedParty).toList();
    }

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      list = list.where((m) => m.matchesQuery(_searchQuery)).toList();
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  Future<void> _loadData() async {
    final members = await MemberDataService.loadMembers();
    final states = await MemberDataService.getStates();
    final parties = await MemberDataService.getParties();
    if (mounted) {
      setState(() {
        _allMembers = members;
        _states = ['All States', ...states];
        _parties = ['All Parties', ...parties];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildSearchHeader(),
              _buildFilterRow(),
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1B2A4A),
                    ),
                  ),
                )
              else
                Expanded(
                  child: _searchQuery.isEmpty &&
                          _selectedState == 'All States' &&
                          _selectedParty == 'All Parties'
                      ? _buildIdleContent()
                      : _buildSearchResults(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Search Header ─────────────────────────────────────────────
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF1B2A4A), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF1B2A4A),
                ),
                decoration: InputDecoration(
                  hintText: 'Search name, party, constituency, state...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF7A8BA5), size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E4EA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Color(0xFF4A5568), size: 14),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter Row (State & Party dropdowns) ──────────────────────
  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(child: _buildDropdown(_selectedState, _states, (val) {
            setState(() => _selectedState = val!);
          })),
          const SizedBox(width: 10),
          Expanded(child: _buildDropdown(_selectedParty, _parties, (val) {
            setState(() => _selectedParty = val!);
          })),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E4EA)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF7A8BA5), size: 20),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1B2A4A),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1B2A4A),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── Idle Content ──────────────────────────────────────────────
  Widget _buildIdleContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B2A4A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _recentSearches.clear());
                  },
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A90D9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((term) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = term;
                    setState(() => _searchQuery = term);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8ECF0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history_rounded,
                            size: 14, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Text(
                          term,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4A5568),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 28),

          // Quick stats
          Text(
            'Parliament Overview',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2A4A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  Icons.people_outline,
                  '${_allMembers.length}',
                  'Total Members',
                  const Color(0xFF4A90D9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  Icons.how_to_vote_outlined,
                  '${_allMembers.where((m) => m.isSitting).length}',
                  'Sitting Members',
                  const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  Icons.map_outlined,
                  '${_states.length - 1}',
                  'States / UTs',
                  const Color(0xFFE67E22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  Icons.flag_outlined,
                  '${_parties.length - 1}',
                  'Political Parties',
                  const Color(0xFF9B59B6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Top experienced members
          Text(
            'Most Experienced Members',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2A4A),
            ),
          ),
          const SizedBox(height: 12),
          ..._getTopExperiencedMembers()
              .map((m) => _buildCompactMemberTile(m)),
        ],
      ),
    );
  }

  List<LokSabhaMember> _getTopExperiencedMembers() {
    final sorted = List<LokSabhaMember>.from(_allMembers)
      ..sort((a, b) => b.termCount.compareTo(a.termCount));
    return sorted.take(5).toList();
  }

  Widget _buildCompactMemberTile(LokSabhaMember m) {
    return GestureDetector(
      onTap: () => _openProfile(m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F2F5)),
        ),
        child: Row(
          children: [
            _buildMemberAvatar(m.imageUrl, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B2A4A),
                    ),
                  ),
                  Text(
                    '${m.party} • ${m.constituency}, ${m.state}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF7A8BA5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90D9).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${m.termCount} terms',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A90D9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2A4A),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF7A8BA5),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Results ────────────────────────────────────────────
  Widget _buildSearchResults() {
    final results = _filteredMembers;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2F8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 48, color: Color(0xFFB0BEC5)),
            ),
            const SizedBox(height: 16),
            Text(
              'No members found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B2A4A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try different keywords or filters',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF7A8BA5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
          child: Text(
            '${results.length} member${results.length != 1 ? 's' : ''} found',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7A8BA5),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _buildSearchResultCard(results[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(LokSabhaMember m) {
    final Color statusColor;
    final String statusLabel;
    switch (m.membershipStatus) {
      case 'SITTING':
        statusColor = const Color(0xFF2ECC71);
        statusLabel = 'Sitting';
        break;
      case 'DIED':
        statusColor = const Color(0xFF7A8BA5);
        statusLabel = 'Deceased';
        break;
      default:
        statusColor = const Color(0xFFE67E22);
        statusLabel = m.membershipStatus;
    }

    return GestureDetector(
      onTap: () => _openProfile(m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Member photo
                _buildMemberAvatar(m.imageUrl, radius: 28),
                const SizedBox(width: 14),
                // Name, constituency, state
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B2A4A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${m.constituency}, ${m.state}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF7A8BA5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Party badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              m.party,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4A90D9),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Status dot
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom info row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Terms served
                  const Icon(Icons.how_to_vote_outlined,
                      color: Color(0xFF7A8BA5), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${m.termCount} term${m.termCount != 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A5568),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Lok Sabha numbers
                  const Icon(Icons.event_outlined,
                      color: Color(0xFF7A8BA5), size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'LS: ${m.lokSabhaTerms.join(', ')}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF4A5568),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (m.dob.isNotEmpty) ...[
                    const Icon(Icons.cake_outlined,
                        color: Color(0xFF7A8BA5), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      m.dob,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Member Avatar (with CachedNetworkImage) ───────────────────
  Widget _buildMemberAvatar(String imageUrl, {double radius = 28}) {
    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: const Color(0xFFF0F2F8),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF7A8BA5),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: const Color(0xFF3A4F6F),
            child: Icon(Icons.person, color: Colors.white60, size: radius),
          ),
        ),
      ),
    );
  }

  // ─── Navigation ────────────────────────────────────────────────
  void _openProfile(LokSabhaMember m) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemberDetailScreen(member: m),
      ),
    );
  }
}
