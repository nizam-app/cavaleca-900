import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);

class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({
    super.key,
    this.isGuest = false,
    this.onSignUp,
  });
  static const String routeName = '/customerNotifications';

  final bool isGuest;
  final VoidCallback? onSignUp;

  @override
  Widget build(BuildContext context) {
    // dummy data – React er moto
    final List<_NotificationItem> notifications = [
      _NotificationItem(
        id: 1,
        title: 'Technician On The Way',
        message: 'John Smith is heading to your location. ETA: 15 minutes',
        time: '10 minutes ago',
        unread: true,
        type: NotificationType.status,
      ),
      _NotificationItem(
        id: 2,
        title: 'Service Completed',
        message: 'Your HVAC maintenance has been completed successfully',
        time: '2 hours ago',
        unread: true,
        type: NotificationType.completed,
      ),
      _NotificationItem(
        id: 3,
        title: 'Rate Your Experience',
        message: 'How was your service with Mike Davis?',
        time: '1 day ago',
        unread: false,
        type: NotificationType.rating,
      ),
      _NotificationItem(
        id: 4,
        title: 'New Message',
        message: 'Sarah Johnson sent you a message about your upcoming booking',
        time: '2 days ago',
        unread: false,
        type: NotificationType.message,
      ),
      _NotificationItem(
        id: 5,
        title: 'Upcoming Service',
        message: 'Your electrical repair is scheduled for tomorrow at 10:00 AM',
        time: '2 days ago',
        unread: false,
        type: NotificationType.reminder,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420.w,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _NotificationsHeader(),
                      SizedBox(height: 16.h),
                      // -------- Guest view ----------
                      if (isGuest) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                          child: _GuestLimitedCard(onSignUp: onSignUp),
                        ),
                      ] else ...[
                        // -------- Normal notifications list ----------
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                          child: Column(
                            children: [
                              for (final item in notifications)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12.0.h),
                                  child: _NotificationCard(item: item),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
///  HEADER  (red gradient, title + subtitle)
/// ---------------------------------------------------------------------------
class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryRed, kPrimaryRedDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Stay updated with your services',
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
///  GUEST CARD (Guest Access Limited)
/// ---------------------------------------------------------------------------
class _GuestLimitedCard extends StatelessWidget {
  const _GuestLimitedCard({this.onSignUp});

  final VoidCallback? onSignUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB111).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.error_outline,
                  color: Color(0xFFFFB111),
                  size: 32.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Guest Access Limited',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Create an account to receive notifications about your bookings and services',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Color(0xFF6B7280)),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: onSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
///  NOTIFICATION CARD
/// ---------------------------------------------------------------------------

enum NotificationType { status, completed, rating, message, reminder }

class _NotificationItem {
  final int id;
  final String title;
  final String message;
  final String time;
  final bool unread;
  final NotificationType type;

  const _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.unread,
    required this.type,
  });
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final _IconStyles iconStyles = _mapTypeToIconStyles(item.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: item.unread
            ? Border(
                left: BorderSide(color: kPrimaryRed, width: 4.w),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon box
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconStyles.bgColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                iconStyles.iconData,
                color: iconStyles.iconColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      if (item.unread)
                        Container(
                          width: 8.r,
                          height: 8.r,
                          margin: EdgeInsets.only(left: 6.w, top: 2.h),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimaryRed,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.time,
                    style: TextStyle(fontSize: 11.sp, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _IconStyles _mapTypeToIconStyles(NotificationType type) {
    switch (type) {
      case NotificationType.status:
        return _IconStyles(
          iconData: Icons.access_time,
          iconColor: const Color(0xFF2563EB),
          bgColor: const Color(0xFFDBEAFE),
        );
      case NotificationType.completed:
        return _IconStyles(
          iconData: Icons.check_circle,
          iconColor: const Color(0xFF16A34A),
          bgColor: const Color(0xFFD1FAE5),
        );
      case NotificationType.rating:
        return _IconStyles(
          iconData: Icons.star,
          iconColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFEF3C7),
        );
      case NotificationType.message:
        return _IconStyles(
          iconData: Icons.chat_bubble_outline,
          iconColor: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFEDE9FE),
        );
      case NotificationType.reminder:
        return _IconStyles(
          iconData: Icons.error_outline,
          iconColor: const Color(0xFFF97316),
          bgColor: const Color(0xFFFFEDD5),
        );
    }
  }
}

class _IconStyles {
  final IconData iconData;
  final Color iconColor;
  final Color bgColor;

  const _IconStyles({
    required this.iconData,
    required this.iconColor,
    required this.bgColor,
  });
}
