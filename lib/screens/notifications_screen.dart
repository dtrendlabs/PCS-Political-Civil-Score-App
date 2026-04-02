import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'icon': Icons.trending_up,
      'color': const Color(0xFF4A90D9),
      'category': 'Score Update',
      'categoryColor': const Color(0xFF4A90D9),
      'title': 'Civil Score Recalculated',
      'body':
          'Sen. Alistair Vance\'s score dropped from 71 to 68 following the campaign finance inquiry.',
      'time': '15 min ago',
      'isRead': false,
    },
    {
      'id': 2,
      'icon': Icons.check_circle_outline,
      'color': const Color(0xFF2ECC71),
      'category': 'Grievance Update',
      'categoryColor': const Color(0xFF2ECC71),
      'title': 'Grievance #1204 Resolved',
      'body':
          'Your grievance regarding road infrastructure in District 5 has been marked as resolved.',
      'time': '2h ago',
      'isRead': false,
    },
    {
      'id': 3,
      'icon': Icons.gavel,
      'color': const Color(0xFFE74C3C),
      'category': 'Legal Alert',
      'categoryColor': const Color(0xFFE74C3C),
      'title': 'New Case Filed — FIN26-CR-901',
      'body':
          'A new campaign finance violation case has been opened against Sen. R. Thornton.',
      'time': '4h ago',
      'isRead': true,
    },
    {
      'id': 4,
      'icon': Icons.campaign_outlined,
      'color': const Color(0xFFE67E22),
      'category': 'System Alert',
      'categoryColor': const Color(0xFFE67E22),
      'title': 'Monthly Report Available',
      'body':
          'The March 2026 Civil Accountability Report is now available for download.',
      'time': '1d ago',
      'isRead': true,
    },
    {
      'id': 5,
      'icon': Icons.person_add_outlined,
      'color': const Color(0xFF9B59B6),
      'category': 'Score Update',
      'categoryColor': const Color(0xFF4A90D9),
      'title': 'New Official Added',
      'body':
          'Rep. Diana Kowalski (District 11) has been added to the Civil Ledger registry.',
      'time': '2d ago',
      'isRead': true,
    },
    {
      'id': 6,
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFE67E22),
      'category': 'System Alert',
      'categoryColor': const Color(0xFFE67E22),
      'title': 'Investigation Update',
      'body':
          'Zoning irregularity investigation in District 3 has been elevated to formal inquiry.',
      'time': '3d ago',
      'isRead': true,
    },
  ];

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  void _dismissNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  void _toggleRead(int id) {
    setState(() {
      final n = _notifications.firstWhere((n) => n['id'] == id);
      n['isRead'] = !(n['isRead'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !(n['isRead'] as bool)).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1B2A4A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B2A4A),
          ),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A90D9),
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread count badge
                if (unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4A90D9),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4A90D9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Notification list
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return _buildNotificationTile(n);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> n) {
    final isRead = n['isRead'] as bool;

    return Dismissible(
      key: Key('notif_${n['id']}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _dismissNotification(n['id'] as int),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _toggleRead(n['id'] as int),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFF0F5FF),
            borderRadius: BorderRadius.circular(16),
            border: isRead
                ? null
                : Border.all(
                    color: const Color(0xFF4A90D9).withAlpha(50), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (n['color'] as Color).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(n['icon'] as IconData,
                    color: n['color'] as Color, size: 20),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                (n['categoryColor'] as Color).withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            n['category'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: n['categoryColor'] as Color,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Text(
                          n['time'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF7A8BA5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      n['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                            isRead ? FontWeight.w500 : FontWeight.w600,
                        color: const Color(0xFF1B2A4A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Body
                    Text(
                      n['body'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF7A8BA5),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Unread dot
              if (!isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A90D9),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 56,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2A4A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No new notifications',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF7A8BA5),
            ),
          ),
        ],
      ),
    );
  }
}
