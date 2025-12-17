import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../screen/job/model/internal_job_model.dart';

class Newjobassigned extends StatefulWidget {
  const Newjobassigned(
    this.job, {
    super.key,

    this.initialSeconds = 20,
    required this.onClose,
    required this.onAccept,
    required this.onDecline,
    this.onTimeout,
  });

  final InternalJob job;
  final int initialSeconds;
  final VoidCallback onClose;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onTimeout;

  @override
  State<Newjobassigned> createState() => _NewjobassignedState();
}

class _NewjobassignedState extends State<Newjobassigned> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        timer.cancel();
        if (widget.onTimeout != null) {
          widget.onTimeout!();
        }
        setState(() {});
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _priorityColor(JobPriority? priority) {
    switch (priority) {
      case JobPriority.high:
        return const Color(0xFFDC2626); // red
      case JobPriority.medium:
        return const Color(0xFFF59E0B); // yellow
      case JobPriority.low:
        return const Color(0xFF16A34A); // green
      default:
        return const Color(0xFF9CA3AF); // gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Material(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Container(
          width: 0.9.sw,
          constraints: BoxConstraints(maxWidth: 420.w, maxHeight: 0.9.sh),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // -------- top close button row --------
              Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
                child: Row(
                  children: [
                    const Spacer(),
                    InkWell(
                      onTap: widget.onClose,
                      child: Icon(
                        Icons.close_rounded,
                        size: 20.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // -------- bell + title + subtitle + countdown --------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE4E6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: const Color(0xFFDC2626),
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'New Job Assigned!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'You have ${widget.initialSeconds} seconds to respond',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _formattedTime,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // -------- job card --------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title + priority badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              job.title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ),
                          if (job.priority != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                job.priority!.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _priorityColor(job.priority),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        job.category ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFDC2626),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // customer
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: job.customer,
                        secondary: job.customerPhone,
                      ),
                      SizedBox(height: 6.h),

                      // location
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: job.location,
                        secondary: job.address,
                      ),
                      SizedBox(height: 6.h),

                      // date & time
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label:
                            '${job.date}${job.time != null ? ' at ${job.time}' : ''}',
                      ),

                      SizedBox(height: 10.h),
                      Divider(color: const Color(0xFFE5E7EB), height: 1.h),
                      SizedBox(height: 8.h),

                      // description
                      if (job.description != null &&
                          job.description!.isNotEmpty)
                        Text(
                          job.description!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF4B5563),
                          ),
                        ),

                      SizedBox(height: 12.h),

                      // Payment card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF3),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            // labels
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Job Payment',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF059669),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    job.payment,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF14532D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Your Commission (5%)',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF059669),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  job.bonus.isNotEmpty
                                      ? '+${job.bonus}'
                                      : '+\$0.00',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF14532D),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // -------- bottom buttons --------
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9FAFB),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: widget.onDecline,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: widget.onAccept,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: Text(
                            'Accept Job',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.secondary});

  final IconData icon;
  final String label;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: secondary != null
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF9CA3AF)),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF111827),
                ),
              ),
              if (secondary != null && secondary!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  secondary!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
