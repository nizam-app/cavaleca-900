import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

const kPrimaryRed = Color(0xFFC20001);
const kPrimaryBlue = Color(0xFF2563EB);
const kSheetBg = Colors.white;
const kDialogShadow = BoxShadow(
  color: Color(0x22000000),
  blurRadius: 18,
  offset: Offset(0, 6),
);

enum BookingStatus { inProgress, completed, cancelled }

class BookingDetails {
  final BookingStatus status;
  final String serviceName;
  final String category;
  final String description;
  final String scheduledText;
  final String location;
  final String technicianName;
  final String technicianPhone;

  BookingDetails({
    required this.status,
    required this.serviceName,
    required this.category,
    required this.description,
    required this.scheduledText,
    required this.location,
    required this.technicianName,
    required this.technicianPhone,
  });
}

/// call this from any screen:
/// await showBookingDetailsDialog(context, details);
Future<void> showBookingDetailsDialog(
  BuildContext context, {
  required BookingDetails details,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'booking_details'.tr(),
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (_, __, ___) {
      return _BookingDetailsDialog(details: details);
    },
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _BookingDetailsDialog extends StatelessWidget {
  const _BookingDetailsDialog({required this.details});

  final BookingDetails details;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        // full overlay like TSX DialogContent
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 420,
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: kSheetBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [kDialogShadow],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 16),
                      _buildStatusPill(details.status),
                      const SizedBox(height: 16),
                      _buildServiceCard(),
                      const SizedBox(height: 12),
                      _buildScheduledCard(),
                      const SizedBox(height: 12),
                      _buildLocationCard(),
                      const SizedBox(height: 12),
                      _buildTechnicianCard(),
                      const SizedBox(height: 20),
                      _buildCloseButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- header ----------------

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Text(
              'booking_details'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.close,
                size: 20,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
         Text(
          'view_booking_info'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  // ---------------- status pill ----------------

  Widget _buildStatusPill(BookingStatus status) {
    String text;
    Color bg;
    Color fg;

    switch (status) {
      case BookingStatus.inProgress:
        text = 'in_progress'.tr();
        bg = const Color(0xFFE0EDFF);
        fg = kPrimaryBlue;
        break;
      case BookingStatus.completed:
        text = 'completed'.tr();
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        break;
      case BookingStatus.cancelled:
        text = 'completed'.tr();
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 10, color: fg),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- cards ----------------

  Widget _buildServiceCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'service'.tr(),
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 4),
          Text(
            details.serviceName,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
           Text(
            'category'.tr(),
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 4),
          Text(
            details.category,
            style: const TextStyle(
              fontSize: 13,
              color: kPrimaryRed,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
           Text(
            'description'.tr(),
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 4),
          Text(
            details.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledCard() {
    return _Card(
      child: Row(
        children: [
          _circleIcon(
            icon: Icons.schedule,
            bg: const Color(0xFFE0EDFF),
            iconColor: kPrimaryBlue,
          ),
          const SizedBox(width: 12),
           Text(
            'scheduled'.tr(),
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              details.scheduledText,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return _Card(
      child: Row(
        children: [
          _circleIcon(
            icon: Icons.location_on_outlined,
            bg: const Color(0xFFFEE2E2),
            iconColor: kPrimaryRed,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'location'.tr(),
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 4),
                Text(
                  details.location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard() {
    final initials = _initialsFromName(details.technicianName);

    return _Card(
      child: Row(
        children: [
          // avatar
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryRed,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'assigned_technician'.tr(),
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 4),
                Text(
                  details.technicianName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details.technicianPhone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // call button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone, color: kPrimaryRed, size: 20),
          ),
        ],
      ),
    );
  }

  // ---------------- footer ----------------

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child:  Text(
          'close'.tr(),
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ---------------- helpers ----------------

  Widget _circleIcon({
    required IconData icon,
    required Color bg,
    required Color iconColor,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.isEmpty ? 'T' : name[0].toUpperCase();
  }
}

// simple reusable card with same radius/shadow
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSheetBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
