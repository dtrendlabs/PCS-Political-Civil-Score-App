import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../src/data/politicians_data.dart';
import '../src/services/gemini_service.dart';

class MemberDetailScreen extends StatefulWidget {
  final LokSabhaMember member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  Map<String, dynamic>? _detailData;
  bool _isLoading = true;
  bool _hasError = false;
  String _dataSource = ''; // 'gemini' or 'local'

  @override
  void initState() {
    super.initState();
    _loadDetailData();
  }

  Future<void> _loadDetailData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Try Gemini API first
      final geminiData =
          await GeminiService.fetchCandidateProfile(widget.member);

      if (geminiData != null && mounted) {
        setState(() {
          _detailData = geminiData;
          _isLoading = false;
          _dataSource = 'gemini';
        });
        return;
      }

      // Fallback: load from local static JSON
      final jsonString =
          await rootBundle.loadString('lib/src/candidate_details.json');
      final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
      if (list.isNotEmpty && mounted) {
        setState(() {
          _detailData = list[0] as Map<String, dynamic>;
          _isLoading = false;
          _dataSource = 'local';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = _detailData == null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoadingState()
                : _hasError
                    ? _buildErrorState()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xFF4A90D9),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Fetching profile from Gemini AI...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7A8BA5),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Analyzing public records & affidavits',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 36, color: Color(0xFFE74C3C)),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load profile',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B2A4A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check your internet or API key',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF7A8BA5),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDetailData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2A4A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sliver App Bar with member photo ──────────────────────────
  Widget _buildSliverAppBar() {
    final m = widget.member;
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF1B2A4A),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(50),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B2A4A), Color(0xFF263B5E)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Member photo
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: m.isSitting
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFF7A8BA5),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: CachedNetworkImage(
                        imageUrl: m.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, url) => Container(
                          color: const Color(0xFF3A4F6F),
                          child: const Icon(Icons.person,
                              color: Colors.white54, size: 48),
                        ),
                        errorWidget: (_, url, error) => Container(
                          color: const Color(0xFF3A4F6F),
                          child: const Icon(Icons.person,
                              color: Colors.white54, size: 48),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Status tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: m.isSitting
                        ? const Color(0xFF2ECC71).withAlpha(40)
                        : const Color(0xFF7A8BA5).withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: m.isSitting
                          ? const Color(0xFF2ECC71).withAlpha(100)
                          : const Color(0xFF7A8BA5).withAlpha(100),
                    ),
                  ),
                  child: Text(
                    m.membershipStatus,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: m.isSitting
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFF7A8BA5),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    m.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Party & constituency
                Text(
                  '${m.party} • ${m.constituency}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Content ───────────────────────────────────────────────────
  Widget _buildContent() {
    final m = widget.member;
    final detail = _detailData;

    final profile =
        detail?['candidate_profile'] as Map<String, dynamic>? ?? {};
    final financial =
        detail?['financial_summary'] as Map<String, dynamic>? ?? {};
    final criminal =
        detail?['criminal_background'] as Map<String, dynamic>? ?? {};
    final business =
        detail?['business_and_contracts'] as Map<String, dynamic>? ?? {};
    final controversies =
        detail?['controversies_and_notes'] as Map<String, dynamic>? ?? {};

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        children: [
          // Quick info chips
          _buildQuickInfoRow(m),
          const SizedBox(height: 20),

          // 1. Candidate Profile
          _buildSection(
            icon: Icons.person_outline,
            title: 'Candidate Profile',
            color: const Color(0xFF4A90D9),
            child: _buildProfileDetails(profile, m),
          ),
          const SizedBox(height: 16),

          // 2. Financial Summary
          _buildSection(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Financial Summary',
            color: const Color(0xFF2ECC71),
            child: _buildFinancialDetails(financial),
          ),
          const SizedBox(height: 16),

          // 3. Criminal Background
          _buildSection(
            icon: Icons.gavel_outlined,
            title: 'Criminal Background',
            color: const Color(0xFFE74C3C),
            child: _buildCriminalDetails(criminal),
          ),
          const SizedBox(height: 16),

          // 4. Business & Contracts
          _buildSection(
            icon: Icons.business_center_outlined,
            title: 'Business & Contracts',
            color: const Color(0xFFE67E22),
            child: _buildBusinessDetails(business),
          ),
          const SizedBox(height: 16),

          // 5. Controversies & Notes
          _buildSection(
            icon: Icons.report_outlined,
            title: 'Controversies & Notes',
            color: const Color(0xFF9B59B6),
            child: _buildControversyDetails(controversies),
          ),

          const SizedBox(height: 16),

          // Data source indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _dataSource == 'gemini'
                  ? const Color(0xFFF0F4FF)
                  : const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _dataSource == 'gemini'
                      ? Icons.auto_awesome
                      : Icons.storage_outlined,
                  size: 14,
                  color: _dataSource == 'gemini'
                      ? const Color(0xFF4A90D9)
                      : const Color(0xFF7A8BA5),
                ),
                const SizedBox(width: 6),
                Text(
                  _dataSource == 'gemini'
                      ? 'Generated by Google Gemini AI'
                      : 'Loaded from local data',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _dataSource == 'gemini'
                        ? const Color(0xFF4A90D9)
                        : const Color(0xFF7A8BA5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick Info Row ────────────────────────────────────────────
  Widget _buildQuickInfoRow(LokSabhaMember m) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoChip(
            Icons.how_to_vote_outlined,
            '${m.termCount} Terms',
            const Color(0xFF4A90D9),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildInfoChip(
            Icons.location_on_outlined,
            m.state,
            const Color(0xFF2ECC71),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildInfoChip(
            Icons.event_outlined,
            'LS ${m.lokSabhaTerms.last}',
            const Color(0xFFE67E22),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2A4A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Section Card ──────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B2A4A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ─── 1. Candidate Profile ─────────────────────────────────────
  Widget _buildProfileDetails(
      Map<String, dynamic> profile, LokSabhaMember m) {
    return Column(
      children: [
        _buildDetailRow('Full Name', profile['name'] ?? m.name),
        _buildDetailRow('Age', '${profile['age'] ?? 'N/A'}'),
        _buildDetailRow("Father's Name", profile['father_name'] ?? 'N/A'),
        _buildDetailRow('Party', profile['party'] ?? m.party),
        _buildDetailRow(
            'Constituency', profile['constituency'] ?? m.constituency),
        _buildDetailRow('Profession', profile['profession'] ?? 'N/A'),
        _buildDetailRow('Education', profile['education'] ?? 'N/A'),
        _buildDetailRow(
            'Voter Enrollment', profile['voter_enrollment'] ?? 'N/A',
            isLast: true),
      ],
    );
  }

  // ─── 2. Financial Summary ─────────────────────────────────────
  Widget _buildFinancialDetails(Map<String, dynamic> financial) {
    final totalAssets =
        financial['total_assets'] as Map<String, dynamic>? ?? {};
    final movable =
        financial['movable_assets_breakdown'] as Map<String, dynamic>? ?? {};
    final taxStatus =
        financial['income_tax_status'] as Map<String, dynamic>? ?? {};
    final bankDeposits =
        movable['bank_deposits'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Assets summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F8EF), Color(0xFFF0FAF5)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Total Assets',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF7A8BA5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalAssets['grand_total'] ?? 'N/A',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B2A4A),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAssetTag(
                      'Movable', totalAssets['movable'] ?? 'Nil', true),
                  const SizedBox(width: 12),
                  _buildAssetTag(
                      'Immovable', totalAssets['immovable'] ?? 'Nil', false),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Movable breakdown
        _buildDetailRow(
            'Cash in Hand', movable['cash_in_hand'] ?? 'N/A'),
        _buildDetailRow('Jewelry & Vehicles',
            movable['jewelry_and_vehicles'] ?? 'N/A'),

        // Bank deposits
        if (bankDeposits.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Bank Deposits',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2A4A),
            ),
          ),
          const SizedBox(height: 8),
          ...bankDeposits.map((dep) {
            final deposit = dep as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deposit['bank'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF4A5568),
                      ),
                    ),
                  ),
                  Text(
                    deposit['amount'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B2A4A),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 12),
        _buildDetailRow(
            'Liabilities', financial['liabilities'] ?? 'N/A'),

        // Tax status
        const SizedBox(height: 10),
        Text(
          'Income Tax Status',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B2A4A),
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('PAN Provided', taxStatus['pan_provided'] ?? 'N/A'),
        _buildDetailRow(
            'Last ITR Filed', taxStatus['last_itr_filed'] ?? 'N/A'),
        _buildDetailRow(
            'Total Income Shown', taxStatus['total_income_shown'] ?? 'N/A',
            isLast: true),
      ],
    );
  }

  Widget _buildAssetTag(String label, String value, bool isHighlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFF2ECC71).withAlpha(20)
            : const Color(0xFFF0F2F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: const Color(0xFF7A8BA5),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2A4A),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. Criminal Background ────────────────────────────────────
  Widget _buildCriminalDetails(Map<String, dynamic> criminal) {
    final pendingCases = criminal['total_pending_cases'] ?? 0;
    final charges =
        criminal['serious_charges_summary'] as List<dynamic>? ?? [];
    final caseDetails = criminal['case_details'] as List<dynamic>? ?? [];
    final sources = criminal['sources'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pending cases badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: pendingCases > 0
                ? const Color(0xFFFDE8E8)
                : const Color(0xFFE8F8EF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                pendingCases > 0
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: pendingCases > 0
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFF2ECC71),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                '$pendingCases Pending Case${pendingCases != 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: pendingCases > 0
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
        ),

        // Serious charges
        if (charges.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Serious Charges',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2A4A),
            ),
          ),
          const SizedBox(height: 8),
          ...charges.map((charge) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE74C3C),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      charge.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF4A5568),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // Case details
        if (caseDetails.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Case Details',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2A4A),
            ),
          ),
          const SizedBox(height: 8),
          ...caseDetails.map((caseItem) {
            final c = caseItem as Map<String, dynamic>;
            final status = c['status'] ?? 'Unknown';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFFF0F2F5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          c['fir_no'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B2A4A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: status == 'Pending'
                              ? const Color(0xFFFFF8E7)
                              : const Color(0xFFE8F8EF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: status == 'Pending'
                                ? const Color(0xFFF39C12)
                                : const Color(0xFF2ECC71),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c['sections'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF7A8BA5),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // Source
        if (sources.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: Color(0xFF4A90D9)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Source: $sources',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF4A90D9),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── 4. Business & Contracts ───────────────────────────────────
  Widget _buildBusinessDetails(Map<String, dynamic> business) {
    return Column(
      children: [
        _buildDetailRow(
            'Family Companies', business['handling_family_companies'] ?? 'N/A'),
        _buildDetailRow('Company Turnover',
            business['company_turnover_estimated'] ?? 'N/A'),
        _buildDetailRow(
            'Government Contracts', business['government_contracts'] ?? 'N/A',
            isLast: true),
      ],
    );
  }

  // ─── 5. Controversies & Notes ──────────────────────────────────
  Widget _buildControversyDetails(Map<String, dynamic> controversies) {
    final entries = controversies.entries.toList();
    if (entries.isEmpty) {
      return Text(
        'No controversies or notes on record.',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFF7A8BA5),
        ),
      );
    }

    return Column(
      children: entries.asMap().entries.map((entry) {
        final key = entry.value.key;
        final value = entry.value.value.toString();
        final label = _formatKey(key);

        return Container(
          margin:
              EdgeInsets.only(bottom: entry.key < entries.length - 1 ? 12 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9B59B6),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF4A5568),
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Helper: detail row ────────────────────────────────────────
  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF2F4F7), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF7A8BA5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1B2A4A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helper: format JSON keys to readable labels ───────────────
  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : '')
        .join(' ');
  }
}
