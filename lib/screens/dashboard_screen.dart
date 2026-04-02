import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onSubmitGrievance;
  final VoidCallback? onViewRankings;

  const DashboardScreen({
    super.key,
    this.onSubmitGrievance,
    this.onViewRankings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(),
          const SizedBox(height: 20),
          _buildOverviewCards(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildTopPerformers(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Welcome Banner ──────────────────────────────────────────────
  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B2A4A),
            Color(0xFF2C3E6B),
            Color(0xFF1B3C5A),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Civic Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track political accountability in real-time',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 20),
            // Summary strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withAlpha(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('Score Avg', '72.4', Icons.trending_up),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white24,
                  ),
                  _buildMiniStat('Active', '1,248', Icons.people_outline),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white24,
                  ),
                  _buildMiniStat('Alerts', '14', Icons.warning_amber_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4A90D9), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: Colors.white54,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ─── Overview Cards ──────────────────────────────────────────────
  Widget _buildOverviewCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2A4A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'Politicians\nTracked',
                  '342',
                  Icons.account_balance,
                  const Color(0xFF4A90D9),
                  const Color(0xFFEBF3FD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'Average\nCivil Score',
                  '68.3',
                  Icons.speed,
                  const Color(0xFF2ECC71),
                  const Color(0xFFE8F8EF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'Active\nGrievances',
                  '89',
                  Icons.report_problem_outlined,
                  const Color(0xFFE67E22),
                  const Color(0xFFFFF3E6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'Pending\nInvestigations',
                  '23',
                  Icons.gavel,
                  const Color(0xFFE74C3C),
                  const Color(0xFFFDE8E8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2A4A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF7A8BA5),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick Actions ───────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Submit Grievance',
              Icons.edit_note_rounded,
              const Color(0xFF1B2A4A),
              Colors.white,
              onSubmitGrievance,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'View Rankings',
              Icons.leaderboard_outlined,
              Colors.white,
              const Color(0xFF1B2A4A),
              onViewRankings,
              isBordered: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color bgColor,
    Color fgColor,
    VoidCallback? onTap, {
    bool isBordered = false,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: isBordered
                ? Border.all(color: const Color(0xFFE0E4EA), width: 1.5)
                : null,
            boxShadow: isBordered
                ? null
                : [
                    BoxShadow(
                      color: const Color.fromRGBO(27, 42, 74, 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fgColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Top Performers ──────────────────────────────────────────────
  Widget _buildTopPerformers() {
    final performers = [
      {
        'name': 'Sen. Maria Chen',
        'district': 'District 2',
        'score': 0.92,
        'scoreText': '92',
        'image':
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100&h=100&fit=crop&crop=face',
      },
      {
        'name': 'Gov. James Obi',
        'district': 'State Capital',
        'score': 0.88,
        'scoreText': '88',
        'image':
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop&crop=face',
      },
      {
        'name': 'Rep. Aisha Patel',
        'district': 'District 7',
        'score': 0.85,
        'scoreText': '85',
        'image':
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Performers',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B2A4A),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8EF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'THIS MONTH',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2ECC71),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...performers.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < performers.length - 1 ? 12 : 0),
                child: _buildPerformerTile(
                  rank: i + 1,
                  name: p['name'] as String,
                  district: p['district'] as String,
                  score: p['score'] as double,
                  scoreText: p['scoreText'] as String,
                  imageUrl: p['image'] as String,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerTile({
    required int rank,
    required String name,
    required String district,
    required double score,
    required String scoreText,
    required String imageUrl,
  }) {
    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rankColors[rank - 1].withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: rankColors[rank - 1],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF3A4F6F),
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),
          // Name & district
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B2A4A),
                  ),
                ),
                Text(
                  district,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF7A8BA5),
                  ),
                ),
              ],
            ),
          ),
          // Score
          CircularPercentIndicator(
            radius: 22,
            lineWidth: 4,
            percent: score,
            center: Text(
              scoreText,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2ECC71),
              ),
            ),
            progressColor: const Color(0xFF2ECC71),
            backgroundColor: const Color(0xFFE8ECF0),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }

  // ─── Recent Activity ─────────────────────────────────────────────
  Widget _buildRecentActivity() {
    final activities = [
      {
        'icon': Icons.gavel,
        'color': const Color(0xFFE74C3C),
        'title': 'New case filed against Sen. R. Thornton',
        'subtitle': 'Campaign Finance Violation — FIN26-CR-901',
        'time': '2h ago',
      },
      {
        'icon': Icons.check_circle,
        'color': const Color(0xFF2ECC71),
        'title': 'Grievance #1204 resolved',
        'subtitle': 'Infrastructure complaint in District 5',
        'time': '4h ago',
      },
      {
        'icon': Icons.trending_up,
        'color': const Color(0xFF4A90D9),
        'title': 'Civil Score updated for 12 officials',
        'subtitle': 'Monthly recalculation completed',
        'time': '6h ago',
      },
      {
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFE67E22),
        'title': 'Investigation opened — Zoning irregularities',
        'subtitle': 'District 3 — Multiple officials involved',
        'time': '1d ago',
      },
      {
        'icon': Icons.person_add,
        'color': const Color(0xFF9B59B6),
        'title': 'New official added to registry',
        'subtitle': 'Rep. Diana Kowalski — District 11',
        'time': '2d ago',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B2A4A),
              ),
            ),
            const SizedBox(height: 16),
            ...activities.asMap().entries.map((entry) {
              final i = entry.key;
              final a = entry.value;
              return _buildActivityTile(
                icon: a['icon'] as IconData,
                color: a['color'] as Color,
                title: a['title'] as String,
                subtitle: a['subtitle'] as String,
                time: a['time'] as String,
                isLast: i == activities.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE8ECF0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B2A4A),
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF7A8BA5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF7A8BA5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
