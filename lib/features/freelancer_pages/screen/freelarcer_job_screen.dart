// freelarcer_job_screen.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/internal_technician/screen/job/logic/internal_job_logic.dart';
import 'package:workpleis/features/internal_technician/screen/job/model/internal_job_model.dart';
import 'package:workpleis/features/internal_technician/widget/gPSCheckInPopup.dart';
import 'package:workpleis/features/internal_technician/widget/jobDetails.dart';
import 'package:workpleis/features/internal_technician/widget/viewJobDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workpleis/core/widget/screen_refresh_provider.dart';
import 'package:workpleis/features/nav_bar/logic/botton_nav_index_logic.dart';
import 'package:workpleis/core/services/fcm_service.dart';

import 'package:easy_localization/easy_localization.dart';

///  Colors
const Color kJobsBg = Color(0xFFF4F4F4);
const Color kJobsCard = Colors.white;
const Color kJobsTextMain = Color(0xFF1F2933);
const Color kJobsTextMuted = Color(0xFF9CA3AF);
const Color kJobsHeaderYellow = Color(0xFFFFB111);
const Color kJobsHeaderYellowDark = Color(0xFFE69F0F);
const Color kJobsPrimaryYellow = Color(0xFFFFB111);
const Color kJobsPrimaryBlue = Color(0xFF2563EB);
const Color kJobsSuccess = Color(0xFF16A34A);

/// ------------------------------------------------------
///  Tabs
/// ------------------------------------------------------
enum FreelancerJobsTab { incoming, active, done }

enum PaymentButtonState {
  none,
  submit, // "Please submit payment"
  verifying, // "Payment verifying" (disabled)
  resubmit, // "Resubmit payment"
}

final freelancerJobsTabProvider = StateProvider<FreelancerJobsTab>(
  (ref) => FreelancerJobsTab.incoming,
);

/// ------------------------------------------------------
///  Screen
/// ------------------------------------------------------
class FreelarcerJobScreen extends ConsumerStatefulWidget {
  const FreelarcerJobScreen({super.key});

  static const routeName = '/freelarcerJobScreen';

  @override
  ConsumerState<FreelarcerJobScreen> createState() =>
      _FreelarcerJobScreenState();
}

class _FreelarcerJobScreenState extends ConsumerState<FreelarcerJobScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  List<InternalJob> _incomingJobs = [];
  List<InternalJob> _activeJobs = [];
  List<InternalJob> _completedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadAllJobs();
    
    // Register callback for auto-refresh when job notifications are tapped
    FCMService.onJobNotificationTapped = () {
      if (mounted) {
        _loadAllJobs();
      }
    };
  }

  @override
  void dispose() {
    // Clean up the callback to prevent memory leaks
    FCMService.onJobNotificationTapped = null;
    super.dispose();
  }

  Future<void> _loadAllJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final incoming = await TechnicianJobsApi.fetchJobs('incoming');
      final active = await TechnicianJobsApi.fetchJobs('active');
      final done = await TechnicianJobsApi.fetchJobs('done');

      // Filter jobs according to new rules:
      // - Done/Completed: ONLY jobs with status == PAID_VERIFIED
      // - Active: Include jobs with COMPLETED_PENDING_PAYMENT (needs payment)
      final filteredCompleted = done
          .where((job) => job.status == JobStatus.paidVerified)
          .toList();

      // Active tab should include:
      // - All jobs from 'active' endpoint
      // - Jobs with status COMPLETED_PENDING_PAYMENT (from any endpoint)
      final allJobsForActive = [...active, ...done, ...incoming];
      final filteredActive = allJobsForActive
          .where((job) {
            // Include if it's a normal active job
            if (job.status == JobStatus.assigned || 
                job.status == JobStatus.inProgress ||
                job.status == JobStatus.completed) {
              // But exclude if it's PAID_VERIFIED (should be in completed tab)
              return job.status != JobStatus.paidVerified;
            }
            // Include if it needs payment
            return job.status == JobStatus.completedPendingPayment;
          })
          .toList();

      setState(() {
        _incomingJobs = incoming
            .where((job) => job.status == JobStatus.incoming)
            .toList();
        _activeJobs = filteredActive;
        _completedJobs = filteredCompleted;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  Future<void> _handleAcceptJob(InternalJob job) async {
    try {
      final updated = await TechnicianJobsApi.respondToWorkOrder(
        woId: job.id,
        action: 'ACCEPT',
      );

      // Parse payment values to check if they're zero
      final updatedPaymentValue = double.tryParse(
        updated.payment.replaceAll('\$', '').replaceAll(',', ''),
      ) ?? 0.0;
      
      // Always preserve payment and bonus if API response has 0
      // This ensures we don't lose payment info when API returns $0.00
      final paymentToUse = updatedPaymentValue == 0.0
          ? job.payment 
          : updated.payment;
      
      final bonusToUse = updatedPaymentValue == 0.0
          ? job.bonus 
          : updated.bonus;
      
      final finalUpdated = updated.copyWith(
        payment: paymentToUse,
        bonus: bonusToUse,
      );

      setState(() {
        _incomingJobs = _incomingJobs.where((j) => j.id != job.id).toList();
        _activeJobs = [..._activeJobs, finalUpdated];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('job_accepted_and_moved_to_active'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'failed_to_accept_job'.tr()}: $e')));
      }
    }
  }

  Future<void> _handleRejectJob(InternalJob job) async {
    try {
      await TechnicianJobsApi.respondToWorkOrder(
        woId: job.id,
        action: 'DECLINE',
      );

      setState(() {
        _incomingJobs = _incomingJobs.where((j) => j.id != job.id).toList();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('job_rejected_successfully'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'failed_to_reject_job'.tr()}: $e')));
      }
    }
  }

  Future<void> _handleStartJob(InternalJob job) async {
    // GPS popup dekhao + start API
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Gpscheckinpopup(
        jobAddress: job.address ?? job.location,
        onLocationVerified: (lat, lng) async {
          try {
            final updated = await TechnicianJobsApi.startWorkOrder(
              woId: job.id,
              lat: lat,
              lng: lng,
            );

            // Parse payment values to check if they're zero
            final updatedPaymentValue = double.tryParse(
              updated.payment.replaceAll('\$', '').replaceAll(',', ''),
            ) ?? 0.0;
            
            // Always preserve payment and bonus if API response has 0
            // This ensures we don't lose payment info when API returns $0.00
            final paymentToUse = updatedPaymentValue == 0.0
                ? job.payment 
                : updated.payment;
            final bonusToUse = updatedPaymentValue == 0.0
                ? job.bonus 
                : updated.bonus;
            
            final finalUpdated = updated.copyWith(
              payment: paymentToUse,
              bonus: bonusToUse,
            );

            setState(() {
              _activeJobs = _activeJobs
                  .map((j) => j.id == finalUpdated.id ? finalUpdated : j)
                  .toList();
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('job_started_successfully'.tr())),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('${'failed_to_start_job'.tr()}: $e')));
            }
          }
        },
      ),
    );
  }

  Future<void> _handleJobCompleted(InternalJob completedJob) async {
    // Refresh all job lists to get latest data from server
    // This will automatically place jobs in correct tabs based on status:
    // - COMPLETED_PENDING_PAYMENT → active tab (to show payment button)
    // - PAID_VERIFIED → completed tab
    await _loadAllJobs();
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(freelancerJobsTabProvider);
    
    // Listen for refresh triggers when this screen becomes visible
    ref.listen<int>(screenRefreshTriggerProvider, (previous, next) {
      final currentIndex = ref.read(bottomNavIndexProvider);
      final visibleIndex = ref.read(currentVisibleScreenIndexProvider);
      // Refresh if this is the jobs screen (index 1) and it's currently visible
      if (currentIndex == 1 && visibleIndex == 1) {
        _loadAllJobs();
      }
    });

    // Realtime: when technician:jobs_updated fires, refetch all jobs
    ref.listen<int>(jobsRefreshTriggerProvider, (previous, next) {
      if (mounted) _loadAllJobs();
    });

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kJobsBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: kJobsBg,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    // active tab → jobs already accepted
    // available tab → incoming offers
    // completed tab → done
    return Scaffold(
      backgroundColor: kJobsBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllJobs,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _JobsHeader(),
                SizedBox(height: 16.h),
                _JobsTabs(
                  currentTab: tab,
                  onTabChanged: (newTab) =>
                      ref.read(freelancerJobsTabProvider.notifier).state =
                          newTab,
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Builder(
                    builder: (_) {
                      switch (tab) {
                        case FreelancerJobsTab.incoming:
                          return _ActiveJobsList(
                            jobs: _activeJobs,
                            onStartJob: _handleStartJob,
                            onJobCompleted: _handleJobCompleted,
                          );
                        case FreelancerJobsTab.active:
                          return _AvailableJobsList(
                            jobs: _incomingJobs,
                            onAcceptJob: _handleAcceptJob,
                            onRejectJob: _handleRejectJob,
                          );
                        case FreelancerJobsTab.done:
                          return _CompletedJobsList(jobs: _completedJobs);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Header
/// ------------------------------------------------------
class _JobsHeader extends StatelessWidget {
  const _JobsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 30.h,
        bottom: 14.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kJobsHeaderYellow, kJobsHeaderYellowDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'my_jobs'.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'manage_assignments'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black.withOpacity(0.92),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
///  Tabs
/// ------------------------------------------------------
class _JobsTabs extends StatelessWidget {
  final FreelancerJobsTab currentTab;
  final ValueChanged<FreelancerJobsTab> onTabChanged;

  const _JobsTabs({required this.currentTab, required this.onTabChanged});

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: kJobsCard,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabChip(
                label: _capitalizeFirst('incoming'.tr()),
                selected: currentTab == FreelancerJobsTab.active,
                onTap: () => onTabChanged(FreelancerJobsTab.active),
              ),
            ),
            Expanded(
              child: _TabChip(
                label: _capitalizeFirst('available'.tr()),
                selected: currentTab == FreelancerJobsTab.incoming,
                onTap: () => onTabChanged(FreelancerJobsTab.incoming),
              ),
            ),
            Expanded(
              child: _TabChip(
                label: _capitalizeFirst('completed'.tr()),
                selected: currentTab == FreelancerJobsTab.done,
                onTap: () => onTabChanged(FreelancerJobsTab.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? kJobsHeaderYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: kJobsTextMain,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Active Jobs Tab (accepted + in-progress)
/// ------------------------------------------------------
class _ActiveJobsList extends StatelessWidget {
  final List<InternalJob> jobs;
  final Future<void> Function(InternalJob job) onStartJob;
  final Future<void> Function(InternalJob job) onJobCompleted;

  const _ActiveJobsList({
    required this.jobs,
    required this.onStartJob,
    required this.onJobCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'no_active_jobs_right_now'.tr(),
            style: TextStyle(fontSize: 13.sp, color: kJobsTextMuted),
          ),
        ),
      );
    }

      return Column(
        children: [
          for (final job in jobs) ...[
            _ActiveJobCard(
              job: job,
              onStartJob: onStartJob,
              onJobCompleted: onJobCompleted,
              getPaymentButtonState: (j) {
                // Only check for COMPLETED_PENDING_PAYMENT status
                if (j.status != JobStatus.completedPendingPayment) {
                  return PaymentButtonState.none;
                }
                
                final payments = j.payments ?? [];
                
                // Rule 1: If payments is empty ([]) or null → show action: "Please submit payment"
                if (payments.isEmpty) {
                  return PaymentButtonState.submit;
                }
                
                // Rule 2: If payments has at least one item with status == "PENDING_VERIFICATION" 
                // → show "Resubmit payment" (enabled button)
                // IMPORTANT: Check PENDING_VERIFICATION FIRST (highest priority)
                final hasPendingVerification = payments.any((p) {
                  final status = p.status.toUpperCase().trim();
                  return status == 'PENDING_VERIFICATION';
                });
                
                if (hasPendingVerification) {
                  return PaymentButtonState.resubmit;
                }
                
                // Rule 3: If payments is not empty and there is NO "PENDING_VERIFICATION", 
                // and all existing payments are "REJECTED" → show action: "Resubmit payment"
                final allRejected = payments.every((p) {
                  final status = p.status.toUpperCase().trim();
                  return status == 'REJECTED';
                });
                
                if (allRejected) {
                  return PaymentButtonState.resubmit;
                }
                
                // Default: If payments exist but don't match above conditions → "Please submit payment"
                return PaymentButtonState.submit;
              },
              showPaymentSubmitDialog: (j) async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => PaymentSubmitBottomSheet(
                    job: j,
                    onPaymentSubmitted: () {
                      // Refresh handled by parent
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
          ],
        ],
      );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final InternalJob job;
  final Future<void> Function(InternalJob job) onStartJob;
  final Future<void> Function(InternalJob job) onJobCompleted;
  final PaymentButtonState Function(InternalJob) getPaymentButtonState;
  final Future<void> Function(InternalJob) showPaymentSubmitDialog;

  const _ActiveJobCard({
    required this.job,
    required this.onStartJob,
    required this.onJobCompleted,
    required this.getPaymentButtonState,
    required this.showPaymentSubmitDialog,
  });

  Widget _buildStatusBadge(InternalJob job) {
    // Use backend status string if available, otherwise format from enum
    String statusText;
    Color backgroundColor;
    Color textColor;

    // Get backend status string or format from enum
    if (job.backendStatus != null && job.backendStatus!.isNotEmpty) {
      // Format backend status: "COMPLETED_PENDING_PAYMENT" -> "Completed Pending Payment"
      statusText = _formatStatusString(job.backendStatus!);
    } else {
      // Fallback to enum-based text
      switch (job.status) {
        case JobStatus.incoming:
          statusText = 'Incoming';
          break;
        case JobStatus.assigned:
          statusText = 'Assigned';
          break;
        case JobStatus.inProgress:
          statusText = 'In Progress';
          break;
        case JobStatus.completed:
          statusText = 'Completed';
          break;
        case JobStatus.completedPendingPayment:
          statusText = 'Completed Pending Payment';
          break;
        case JobStatus.paidVerified:
          statusText = 'Paid Verified';
          break;
      }
    }

    // Set colors based on status
    switch (job.status) {
      case JobStatus.incoming:
        backgroundColor = const Color(0xFFFFF5F5);
        textColor = const Color(0xFFC20001);
        break;
      case JobStatus.assigned:
        backgroundColor = const Color(0xFFFFF4D7);
        textColor = const Color(0xFFE6A400);
        break;
      case JobStatus.inProgress:
        backgroundColor = const Color(0xFFE5F1FF);
        textColor = kJobsPrimaryBlue;
        break;
      case JobStatus.completed:
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      case JobStatus.completedPendingPayment:
        backgroundColor = const Color(0xFFFFF4E6);
        textColor = const Color(0xFFB45309);
        break;
      case JobStatus.paidVerified:
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  /// Format backend status string to readable format
  /// "COMPLETED_PENDING_PAYMENT" -> "Completed Pending Payment"
  /// "IN_PROGRESS" -> "In Progress"
  /// "ACCEPTED" -> "Accepted"
  String _formatStatusString(String backendStatus) {
    return backendStatus
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Widget _buildPaymentStatusInfo(InternalJob job) {
    // Only show status for COMPLETED_PENDING_PAYMENT jobs
    if (job.status != JobStatus.completedPendingPayment) {
      return const SizedBox.shrink();
    }

    final payments = job.payments ?? [];
    
    // If payments is empty, don't show status
    if (payments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Check overall payment status (priority: PENDING > REJECTED > VERIFIED)
    final pendingCount = payments.where((p) => p.status.toUpperCase() == 'PENDING_VERIFICATION').length;
    final rejectedCount = payments.where((p) => p.status.toUpperCase() == 'REJECTED').length;
    final verifiedCount = payments.where((p) => p.status.toUpperCase() == 'VERIFIED').length;

    String statusText = '';
    Color statusColor = const Color(0xFF6B7280);
    IconData statusIcon = Icons.info_outline;

    // Priority: PENDING_VERIFICATION > REJECTED > VERIFIED
    if (pendingCount > 0) {
      statusText = 'Payment verification pending';
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.access_time;
    } else if (rejectedCount > 0) {
      statusText = 'Rejected ${rejectedCount}x';
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.cancel_outlined;
    } else if (verifiedCount > 0) {
      statusText = 'Payment verified';
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle_outline;
    }

    if (statusText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14.sp,
            color: statusColor,
          ),
          SizedBox(width: 6.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11.sp,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInProgress = job.status == JobStatus.inProgress;
    final address = job.address ?? job.location;
    final dateLabel = '${job.date}${job.time != null ? ' at ${job.time}' : ''}';

    return Container(
      decoration: BoxDecoration(
        color: kJobsCard,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title + status badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: kJobsTextMain,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Customer: ${job.customer}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: kJobsTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(job),
              ],
            ),
            SizedBox(height: 10.h),

            // location + time
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14.sp,
                  color: kJobsTextMuted,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 14.sp, color: kJobsTextMuted),
                SizedBox(width: 4.w),
                Text(
                  dateLabel,
                  style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Divider(color: kJobsTextMuted, height: 1.h),
            SizedBox(height: 6.h),

            // payment + earning
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total_payment'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kJobsTextMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.payment,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: kJobsTextMain,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'your_earning'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: kJobsTextMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.bonus,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: kJobsSuccess,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Payment button for COMPLETED_PENDING_PAYMENT jobs
            if (job.status == JobStatus.completedPendingPayment) ...[
              _buildPaymentStatusInfo(job),
              SizedBox(height: 8.h),
              Builder(
                builder: (context) {
                  final buttonState = getPaymentButtonState(job);
                  
                  if (buttonState == PaymentButtonState.none) {
                    return const SizedBox.shrink();
                  }

                  String buttonText;
                  bool isEnabled;
                  Color backgroundColor;

                  switch (buttonState) {
                    case PaymentButtonState.submit:
                      buttonText = 'Please submit payment';
                      isEnabled = true;
                      backgroundColor = kJobsPrimaryYellow;
                      break;
                    case PaymentButtonState.verifying:
                      buttonText = 'Payment verifying';
                      isEnabled = false;
                      backgroundColor = const Color(0xFF9CA3AF);
                      break;
                    case PaymentButtonState.resubmit:
                      buttonText = 'Resubmit payment';
                      isEnabled = true;
                      backgroundColor = kJobsPrimaryYellow;
                      break;
                    default:
                      return const SizedBox.shrink();
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: 40.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: backgroundColor,
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      onPressed: isEnabled
                          ? () => showPaymentSubmitDialog(job)
                          : null,
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10.h),
            ],

            // bottom button - Hide if payment is pending
            if (job.status != JobStatus.completedPendingPayment)
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () async {
                    if (isInProgress) {
                      await showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => Jobdetails(
                          job: job,
                          onJobCompleted: onJobCompleted,
                        ),
                      );
                    } else {
                      await onStartJob(job);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kJobsPrimaryYellow,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    isInProgress ? 'Continue Job' : 'Start Job',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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

/// ------------------------------------------------------
///  Available Jobs Tab (incoming offers)
/// ------------------------------------------------------
class _AvailableJobsList extends StatelessWidget {
  final List<InternalJob> jobs;
  final Future<void> Function(InternalJob job) onAcceptJob;
  final Future<void> Function(InternalJob job) onRejectJob;

  const _AvailableJobsList({
    required this.jobs,
    required this.onAcceptJob,
    required this.onRejectJob,
  });

  Color _priorityDotColor(JobPriority? priority) {
    switch (priority) {
      case JobPriority.high:
        return Colors.red;
      case JobPriority.medium:
        return Colors.orange;
      case JobPriority.low:
        return Colors.green;
      default:
        return kJobsTextMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'no_available_jobs'.tr(),
            style: TextStyle(fontSize: 13.sp, color: kJobsTextMuted),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final job in jobs) ...[
          Container(
            decoration: BoxDecoration(
              color: kJobsCard,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + urgency + payment
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: kJobsTextMain,
                                ),
                              ),
                            ),
                            Container(
                              height: 8.w,
                              width: 8.w,
                              decoration: BoxDecoration(
                                color: _priorityDotColor(job.priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            job.payment,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: kJobsTextMain,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Earn ${job.bonus}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kJobsSuccess,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // location + date
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: kJobsTextMuted,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          job.address ?? job.location,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: kJobsTextMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: kJobsTextMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        job.date,
                        style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => Viewjobdetails(
                                job: job,
                                bonusRate: 5.0,
                                showAcceptRejectButtons: true,
                                onAccept: () => onAcceptJob(job),
                                onReject: () => onRejectJob(job),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          child: Text(
                            'details'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: kJobsTextMain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => onAcceptJob(job),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kJobsPrimaryYellow,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                          child: Text(
                            'accept_job'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

/// ------------------------------------------------------
///  Completed Jobs Tab
/// ------------------------------------------------------
class _CompletedJobsList extends StatelessWidget {
  final List<InternalJob> jobs;

  const _CompletedJobsList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'no_completed_jobs_yet'.tr(),
            style: TextStyle(fontSize: 13.sp, color: kJobsTextMuted),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final job in jobs) ...[
          Container(
            decoration: BoxDecoration(
              color: kJobsCard,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + check icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: kJobsTextMain,
                          ),
                        ),
                      ),
                      const Icon(Icons.check_circle, color: kJobsSuccess),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Customer: ${job.customer}',
                    style: TextStyle(fontSize: 12.sp, color: kJobsTextMuted),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: kJobsTextMuted,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          job.address ?? job.location,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: kJobsTextMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: kJobsTextMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        job.date,
                        style: TextStyle(fontSize: 12.sp, color: kJobsTextMain),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'earned'.tr(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: kJobsTextMuted,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            job.bonus,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: kJobsSuccess,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

/// Payment Submit/Resubmit Bottom Sheet
class PaymentSubmitBottomSheet extends StatefulWidget {
  final InternalJob job;
  final VoidCallback onPaymentSubmitted;

  const PaymentSubmitBottomSheet({
    super.key,
    required this.job,
    required this.onPaymentSubmitted,
  });

  @override
  State<PaymentSubmitBottomSheet> createState() => _PaymentSubmitBottomSheetState();
}

class _PaymentSubmitBottomSheetState extends State<PaymentSubmitBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _transactionRefController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  String _selectedMethod = 'MOBILE_MONEY';
  XFile? _proofImage;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _requiresProof => _selectedMethod != 'CASH';
  bool get _requiresTransactionRef => _selectedMethod != 'CASH';

  String _friendlyError(Object e) {
    String raw = e.toString();

    // Strip generic Exception prefix
    if (raw.startsWith('Exception: ')) {
      raw = raw.substring('Exception: '.length);
    }

    // Strip common local prefixes
    const prefixes = [
      'Failed to submit payment: ',
      'Failed to submit payment',
    ];
    for (final p in prefixes) {
      if (raw.startsWith(p)) {
        raw = raw.substring(p.length).trim();
        break;
      }
    }

    // Try to parse embedded JSON and extract "message"
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final jsonPart = raw.substring(start, end + 1);
        final obj = jsonDecode(jsonPart);
        if (obj is Map && obj['message'] is String) {
          return obj['message'] as String;
        }
      }
    } catch (_) {
      // ignore JSON parse issues and fall back to raw
    }

    return raw.trim();
  }

  @override
  void initState() {
    super.initState();
    // Auto-populate amount from job.payment
    final paymentAmount = double.tryParse(
      widget.job.payment.replaceAll('\$', '').replaceAll(',', ''),
    ) ?? 0.0;
    _amountController = TextEditingController(
      text: paymentAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionRefController.dispose();
    super.dispose();
  }

  Future<void> _pickProofImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _proofImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Require proof image for all non-cash payments
    if (_requiresProof && _proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload proof image for this payment method')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final amount = double.parse(_amountController.text.trim());
      
      await TechnicianJobsApi.submitPayment(
        woId: widget.job.id,
        amount: amount,
        method: _selectedMethod,
        transactionRef: _transactionRefController.text.trim(),
        proofImage: _proofImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted successfully')),
        );
        widget.onPaymentSubmitted();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error banner at the very top for visibility
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFEF4444),
                            size: 24,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Submit Payment',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: kJobsTextMain,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Amount field (read-only or auto-populated)
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          readOnly: true, // Make it read-only to prevent manual editing
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: kJobsTextMain,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: 'Amount',
                            prefixIcon: const Icon(Icons.attach_money),
                            suffixIcon: Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: Colors.grey.shade400,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Amount is required';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Service price (auto-filled)',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    value: _selectedMethod,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                      helperText: 'Choose how the customer paid',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: kJobsPrimaryYellow),
                      ),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return [
                        const Text('Mobile Money'),
                        const Text('Cash'),
                        const Text('Bank Transfer'),
                      ];
                    },
                    items: [
                       DropdownMenuItem(
                        value: 'CASH',
                        child: Row(
                          children: const [
                            Icon(Icons.attach_money, color: kJobsSuccess),
                            SizedBox(width: 8),
                            Text('Cash'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'MOBILE_MONEY',
                        child: Row(
                          children: const [
                            Icon(Icons.phone_iphone, color: kJobsPrimaryBlue),
                            SizedBox(width: 8),
                            Text('Mobile Money'),
                          ],
                        ),
                      ),
                     
                      DropdownMenuItem(
                        value: 'BANK_TRANSFER',
                        child: Row(
                          children: const [
                            Icon(Icons.account_balance, color: kJobsTextMain),
                            SizedBox(width: 8),
                            Text('Bank Transfer'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMethod = value;
                          // Clear proof image when switching to CASH
                          if (value == 'CASH') {
                            _proofImage = null;
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _transactionRefController,
                    decoration: InputDecoration(
                      labelText: 'Transaction Reference',
                      hintText: _requiresTransactionRef
                          ? 'Enter transaction reference'
                          : 'Enter transaction reference (optional)',
                      prefixIcon: const Icon(Icons.receipt),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(color: kJobsPrimaryYellow),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    validator: (value) {
                      // Transaction ref is required for non-cash
                      if (_requiresTransactionRef && (value == null || value.trim().isEmpty)) {
                        return 'Transaction reference is required for this payment method';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Proof image upload (only for MOBILE_MONEY and BANK_TRANSFER, hidden for CASH)
                  if (_requiresProof) ...[
                    Text(
                      'Proof Image *',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: kJobsTextMain,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _selectedMethod == 'MOBILE_MONEY'
                          ? 'Required for mobile payments'
                          : 'Required for bank transfer payments',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: _pickProofImage,
                      child: Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: _proofImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: Image.file(
                                      File(_proofImage!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.image, size: 48),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 4.h,
                                    right: 4.w,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _proofImage = null;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4.w),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 40.sp,
                                    color: kJobsTextMuted,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Tap to upload proof image',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: kJobsTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kJobsPrimaryYellow,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
