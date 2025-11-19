import 'package:flutter/material.dart';

enum CustomSnackType { info, success, error, warning }
enum SnackPos { top, bottom }

class GlobalSnackBar {
  static OverlayEntry? _entry;

  /// Show a floating snackbar (GetX-style) without GetX.
  static void show(
      BuildContext context, {
        required String title,
        required String message,
        CustomSnackType type = CustomSnackType.info,
        Duration duration = const Duration(seconds: 2),
        SnackPos position = SnackPos.top,
        bool isDismissible = true,
      }) {
    // Remove any existing
    hide();

    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;

    final media = MediaQuery.of(context);
    final safeTop = media.padding.top;
    final safeBottom = media.padding.bottom;

    final cfg = _style(type);

    _entry = OverlayEntry(
      builder: (ctx) {
        final topPos = position == SnackPos.top ? safeTop + 12 : null;
        final bottomPos = position == SnackPos.bottom ? safeBottom + 12 : null;

        return Positioned(
          left: 12,
          right: 12,
          top: topPos,
          bottom: bottomPos,
          child: _SnackCard(
            title: title,
            message: message,
            icon: cfg.icon,
            accent: cfg.accent,
            bg: cfg.bg,
            fg: cfg.fg,
            onClose: isDismissible ? hide : null,
            duration: duration,
          ),
        );
      },
    );

    overlay.insert(_entry!);

    // Auto dismiss
    Future.delayed(duration + const Duration(milliseconds: 200), hide);
  }

  static void hide() {
    _entry?..remove();
    _entry = null;
  }

  static _SnackStyle _style(CustomSnackType t) {
    switch (t) {
      case CustomSnackType.success:
        return _SnackStyle(
          icon: Icons.check_circle_rounded,
          accent: const Color(0xFF2E7D32),
          bg: Colors.white,
          fg: Colors.black87,
        );
      case CustomSnackType.error:
        return _SnackStyle(
          icon: Icons.error_rounded,
          accent: const Color(0xFFC62828),
          bg: Colors.white,
          fg: Colors.black87,
        );
      case CustomSnackType.warning:
        return _SnackStyle(
          icon: Icons.warning_amber_rounded,
          accent: const Color(0xFFED6C02),
          bg: Colors.white,
          fg: Colors.black87,
        );
      case CustomSnackType.info:
      default:
        return _SnackStyle(
          icon: Icons.info_rounded,
          accent: const Color(0xFF1565C0),
          bg: Colors.white,
          fg: Colors.black87,
        );
    }
  }
}

class _SnackStyle {
  final IconData icon;
  final Color accent, bg, fg;
  const _SnackStyle({
    required this.icon,
    required this.accent,
    required this.bg,
    required this.fg,
  });
}

/// Internal visual (GetX-like floating card, top by default)
class _SnackCard extends StatefulWidget {
  const _SnackCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
    required this.bg,
    required this.fg,
    required this.duration,
    this.onClose,
  });

  final String title, message;
  final IconData icon;
  final Color accent, bg, fg;
  final Duration duration;
  final VoidCallback? onClose;

  @override
  State<_SnackCard> createState() => _SnackCardState();
}

class _SnackCardState extends State<_SnackCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 180))
    ..forward();
  late final Animation<Offset> _slide =
  Tween(begin: const Offset(0, -0.15), end: Offset.zero)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
  late final Animation<double> _fade =
  CurvedAnimation(parent: _c, curve: Curves.easeOut);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
          // thin left accent like many toasts
          border: Border(left: BorderSide(color: widget.accent, width: 4)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, color: widget.accent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: widget.fg,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                    child: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.message,
                    style: TextStyle(color: widget.fg.withOpacity(0.85), fontSize: 13.5),
                  ),
                ],
              ),
            ),
            if (widget.onClose != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: widget.onClose,
                child: Icon(Icons.close_rounded, color: widget.fg.withOpacity(0.7), size: 20),
              ),
            ],
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onClose,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(opacity: _fade, child: card),
      ),
    );
  }
}
