// lib/screens/animations/animation_widget/desktop_animation.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class DesktopAnimation extends StatelessWidget {
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color desktopBackgroundColor;
  final bool showGradient;

  // ── NEW: Size configuration ───────────────────────────────────────────────
  final double sizeScale;        // Global scale multiplier (0.0 - 1.0)
  final double fontScale;        // Font scale multiplier (0.0 - 1.0)
  final double spacingScale;     // Spacing scale multiplier (0.0 - 1.0)

  // ── THEME COLORS (White / Black / Green) ──────────────────────────────────
  static const Color accentPrimary   = Color(0xFF00E676);
  static const Color accentSecondary = Color(0xFF4ADE80);
  static const Color accentTertiary  = Color(0xFF22C55E);
  static const Color accentGlow      = Color(0xFFBBF7D0);

  const DesktopAnimation({
    super.key,
    this.width,
    this.height,
    this.backgroundColor        = const Color(0xFF00E676),
    this.desktopBackgroundColor = const Color(0xFF0A0A0A),
    this.showGradient           = true,
    // Size defaults (more compact: ~25% smaller)
    this.sizeScale    = 0.75,
    this.fontScale    = 0.80,
    this.spacingScale = 0.65,
  });

  // ── Helper: scaled value ───────────────────────────────────────────────────
  double _s(double value) => value * sizeScale;
  double _fs(double value) => value * fontScale;
  double _ss(double value) => value * spacingScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_s(24)),
        boxShadow: [
          BoxShadow(
            color: accentPrimary.withOpacity(0.25),
            blurRadius: _s(40),
            offset: Offset(0, _s(12)),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: _s(30),
            offset: Offset(0, _s(8)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_s(24)),
        child: Stack(
          children: [
            if (showGradient) _buildBackgroundPattern(),
            _buildDesktopContent(),
            Positioned(
              top: _s(14),
              left: _s(14),
              child: Row(
                children: [
                  _buildDot(const Color(0xFFFF5F57)),
                  SizedBox(width: _s(6)),
                  _buildDot(const Color(0xFFFEBC2E)),
                  SizedBox(width: _s(6)),
                  _buildDot(const Color(0xFF28C840)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: _s(9),
      height: _s(9),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return CustomPaint(
      painter: _WavePatternPainter(
        color: Colors.white.withOpacity(0.18),
      ),
      child: Container(),
    );
  }

  Widget _buildDesktopContent() {
    return Padding(
      padding: EdgeInsets.fromLTRB(_s(14), _s(36), _s(14), _s(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LEFT SIDE
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(right: _s(8)),
              padding: EdgeInsets.all(_s(11)),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(_s(10)),
                border: Border.all(
                  color: accentPrimary.withOpacity(0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppHeader(),
                  SizedBox(height: _ss(12)),
                  _buildBrandHeader(),
                  SizedBox(height: _ss(14)),
                  Expanded(child: _buildMessagesList()),
                  _buildInputBox(),
                ],
              ),
            ),
          ),

          // RIGHT SIDE
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(_s(11)),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(_s(10)),
                border: Border.all(
                  color: accentPrimary.withOpacity(0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: _fs(10),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: _ss(10)),
                  _buildOptionTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chats',
                    count: 24,
                    color: accentPrimary,
                    isActive: true,
                  ),
                  SizedBox(height: _ss(6)),
                  _buildOptionTile(
                    icon: Icons.mark_chat_unread_outlined,
                    title: 'Unread',
                    count: 7,
                    color: accentSecondary,
                  ),
                  SizedBox(height: _ss(6)),
                  _buildOptionTile(
                    icon: Icons.circle_outlined,
                    title: 'Status',
                    count: 3,
                    color: accentGlow,
                  ),
                  SizedBox(height: _ss(6)),
                  _buildOptionTile(
                    icon: Icons.tag,
                    title: 'Channels',
                    count: 12,
                    color: accentTertiary,
                  ),
                  const Spacer(),
                  _buildAIBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    return Row(
      children: [
        Container(
          width: _s(22),
          height: _s(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [accentPrimary, accentSecondary],
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(_s(5)),
            boxShadow: [
              BoxShadow(
                color: accentPrimary.withOpacity(0.4),
                blurRadius: _s(6),
                offset: Offset(0, _s(1)),
              ),
            ],
          ),
          child: Icon(
            Icons.bolt,
            color: Colors.white,
            size: _s(14),
          ),
        ),
        SizedBox(width: _s(7)),
        Text(
          'QuantMessage',
          style: TextStyle(
            color: Colors.white,
            fontSize: _fs(11),
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.search,
          color: Colors.white.withOpacity(0.5),
          size: _s(14),
        ),
        SizedBox(width: _s(8)),
        Icon(
          Icons.more_horiz,
          color: Colors.white.withOpacity(0.5),
          size: _s(14),
        ),
      ],
    );
  }

  Widget _buildBrandHeader() {
    return Container(
      padding: EdgeInsets.all(_s(9)),
      decoration: BoxDecoration(
        color: accentPrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(_s(8)),
        border: Border.all(
          color: accentPrimary.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _s(28),
            height: _s(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accentPrimary.withOpacity(0.35),
                  accentSecondary.withOpacity(0.35),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome,
                color: accentPrimary,
                size: _s(14),
              ),
            ),
          ),
          SizedBox(width: _s(7)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Inbox',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _fs(10.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Smart message manager',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: _fs(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final messages = [
      _MessageData(
        name: 'Sarah Chen',
        preview: 'Hey! Can you review the design...',
        time: '2m',
        unread: true,
        avatarColor: accentPrimary,
      ),
      _MessageData(
        name: 'AI Assistant',
        preview: 'I\'ve sorted 12 messages by...',
        time: '5m',
        unread: true,
        avatarColor: accentSecondary,
        isAI: true,
      ),
      _MessageData(
        name: 'Dev Team',
        preview: 'Sprint planning at 3 PM...',
        time: '15m',
        unread: false,
        avatarColor: accentGlow,
      ),
      _MessageData(
        name: 'Mike Ross',
        preview: 'The deploy looks good 👍',
        time: '1h',
        unread: false,
        avatarColor: accentTertiary,
      ),
    ];

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: messages.length,
      separatorBuilder: (_, __) => SizedBox(height: _ss(5)),
      itemBuilder: (context, index) {
        return _buildMessageTile(messages[index]);
      },
    );
  }

  Widget _buildMessageTile(_MessageData msg) {
    return Container(
      padding: EdgeInsets.all(_s(7)),
      decoration: BoxDecoration(
        color: msg.unread
            ? accentPrimary.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(_s(6)),
        border: msg.unread
            ? Border.all(color: accentPrimary.withOpacity(0.15))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: _s(24),
            height: _s(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: msg.avatarColor.withOpacity(0.2),
            ),
            child: Center(
              child: msg.isAI
                  ? Icon(
                Icons.auto_awesome,
                size: _s(12),
                color: accentPrimary,
              )
                  : Text(
                msg.name[0],
                style: TextStyle(
                  color: msg.avatarColor,
                  fontSize: _fs(10.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: _s(7)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        msg.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _fs(10),
                          fontWeight: msg.unread
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      msg.time,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: _fs(8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _s(1.5)),
                Text(
                  msg.preview,
                  style: TextStyle(
                    color: msg.unread ? Colors.white70 : Colors.white38,
                    fontSize: _fs(9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (msg.unread)
            Container(
              width: _s(6),
              height: _s(6),
              margin: EdgeInsets.only(left: _s(5)),
              decoration: const BoxDecoration(
                color: accentPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentPrimary,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      margin: EdgeInsets.only(top: _s(8)),
      padding: EdgeInsets.symmetric(
        horizontal: _s(9),
        vertical: _s(7),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(_s(6)),
        border: Border.all(
          color: accentPrimary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add,
            color: Colors.white54,
            size: _s(12),
          ),
          SizedBox(width: _s(5)),
          Expanded(
            child: Text(
              'Ask AI to manage messages...',
              style: TextStyle(
                color: Colors.white38,
                fontSize: _fs(9),
              ),
            ),
          ),
          Icon(
            Icons.send,
            color: accentPrimary,
            size: _s(11),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    bool isActive = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _s(8),
        vertical: _s(7),
      ),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(_s(6)),
        border: Border.all(
          color: isActive ? color.withOpacity(0.4) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _s(22),
            height: _s(22),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_s(5)),
            ),
            child: Icon(icon, color: color, size: _s(11)),
          ),
          SizedBox(width: _s(7)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: _fs(10),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _s(4),
              vertical: _s(1.5),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_s(8)),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: _fs(8.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIBadge() {
    return Container(
      padding: EdgeInsets.all(_s(7)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentPrimary.withOpacity(0.2),
            accentSecondary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(_s(8)),
        border: Border.all(
          color: accentPrimary.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: accentPrimary,
            size: _s(11),
          ),
          SizedBox(width: _s(5)),
          Expanded(
            child: Text(
              'AI Active',
              style: TextStyle(
                color: Colors.white,
                fontSize: _fs(9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: _s(5),
            height: _s(5),
            decoration: const BoxDecoration(
              color: accentPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentPrimary,
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for messages
class _MessageData {
  final String name;
  final String preview;
  final String time;
  final bool unread;
  final Color avatarColor;
  final bool isAI;

  _MessageData({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.avatarColor,
    this.isAI = false,
  });
}

// Custom painter for subtle wave pattern background
class _WavePatternPainter extends CustomPainter {
  final Color color;

  _WavePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Wave 1
    final path = Path();
    final yCenter = size.height * 0.3;

    path.moveTo(0, yCenter);
    for (double x = 0; x <= size.width; x++) {
      path.lineTo(
        x,
        yCenter + math.sin(x / 80) * 15,
      );
    }
    canvas.drawPath(path, paint);

    // Wave 2
    final path2 = Path();
    final y2 = size.height * 0.7;
    path2.moveTo(0, y2);
    for (double x = 0; x <= size.width; x++) {
      path2.lineTo(
        x,
        y2 + math.cos(x / 60) * 12,
      );
    }
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePatternPainter oldDelegate) =>
      oldDelegate.color != color;
}
