import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/notification/data/notificaion_data.dart';
import 'package:workpleis/features/notification/model/notification_model.dart';
import 'package:easy_localization/easy_localization.dart';

const Color kPrimaryRed = Color(0xFFC20001);
const Color kPrimaryRedDark = Color(0xFF9A0001);

class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({
    super.key,
    this.isGuest = false,
    this.onSignUp,
  });

  static const String routeName = '/customerNotifications';

  final bool isGuest;
  final VoidCallback? onSignUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

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

                      if (isGuest) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                          child: _GuestLimitedCard(onSignUp: onSignUp),
                        ),
                      ] else ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.0.w,
                            vertical: 4.h,
                          ),
                          child: notificationsState.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, _) => Column(
                              children: [
                                Text(
                                  'failed_load_notifications'.tr(),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                TextButton(
                                  onPressed: notifier.refresh,
                                  child:  Text('Retry'),
                                ),
                              ],
                            ),
                            data: (list) {
                              if (list.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 40.h),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.notifications_off_outlined,
                                        size: 40.sp,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'no_notifications_yet'.tr(),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final hasUnread = list.any((n) => !n.isRead);

                              return Column(
                                children: [
                                  // Mark all as read row
                                  if (hasUnread)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Recent',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: notifier.markAllAsRead,
                                          child: Text(
                                            'Mark all as read',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: kPrimaryRed,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Recent',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 8.h),

                                  for (final item in list)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 12.0.h),
                                      child: GestureDetector(
                                        onTap: () =>
                                            notifier.markAsRead(item.id),
                                        child: _NotificationCard(item: item),
                                      ),
                                    ),
                                ],
                              );
                            },
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
            'notifications'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'stay_updated'.tr(),
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
              'guest_access_limited'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'create_account_receive_notifications'.tr(),
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
                  'create_account'.tr(),
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

  final FsNotification item;

  @override
  Widget build(BuildContext context) {
    final _IconStyles iconStyles = _mapTypeToIconStyles(item.type);
    final bool unread = !item.isRead;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: unread
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
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      if (unread)
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
                      color: const Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.createdAtFormatted ??
                        timeAgo(item.createdAt), // চাইলে helper বানাও
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _IconStyles _mapTypeToIconStyles(String type) {
    // backend type er উপর ভিত্তি করে আলাদা icon/color
    switch (type) {
      case 'WO_ASSIGNED':
        return const _IconStyles(
          iconData: Icons.assignment_turned_in_outlined,
          iconColor: Color(0xFF2563EB),
          bgColor: Color(0xFFDBEAFE),
        );

      case 'WO_COMPLETED':
        return const _IconStyles(
          iconData: Icons.check_circle_outline,
          iconColor: Color(0xFF16A34A),
          bgColor: Color(0xFFD1FAE5),
        );

      case 'MESSAGE':
        return const _IconStyles(
          iconData: Icons.chat_bubble_outline,
          iconColor: Color(0xFF8B5CF6),
          bgColor: Color(0xFFEDE9FE),
        );

      case 'REMINDER':
        return const _IconStyles(
          iconData: Icons.notifications_active_outlined,
          iconColor: Color(0xFFF97316),
          bgColor: Color(0xFFFFEDD5),
        );

      default:
        // generic / unknown
        return const _IconStyles(
          iconData: Icons.notifications_none,
          iconColor: Color(0xFF6B7280),
          bgColor: Color(0xFFE5E7EB),
        );
    }
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m min${m > 1 ? 's' : ''} ago';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h > 1 ? 's' : ''} ago';
    } else if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d day${d > 1 ? 's' : ''} ago';
    } else {
      // 7 দিনের বেশি হলে শুধু তারিখ দেখাই
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
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
