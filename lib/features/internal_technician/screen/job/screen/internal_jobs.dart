import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:workpleis/features/internal_technician/screen/job/logic/internal_job_logic.dart';
import 'package:workpleis/features/internal_technician/widget/gPSCheckInPopup.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workpleis/core/widget/screen_refresh_provider.dart';
import 'package:workpleis/features/nav_bar/logic/botton_nav_index_logic.dart';

import '../../../widget/jobDetails.dart';
import '../../../widget/viewJobDetails.dart';
import '../../../widget/incomingJobDetails.dart';
import '../model/internal_job_model.dart';

enum PaymentButtonState {
  none,
  submit, // "Please submit payment"
  verifying, // "Payment verifying" (disabled)
  resubmit, // "Resubmit payment"
}

///  Screen

class InternalJobs extends ConsumerStatefulWidget {
  const InternalJobs({super.key});

  static const String routeName = '/internal-jobs';

  @override
  ConsumerState<InternalJobs> createState() => _InternalJobsState();
}

class _InternalJobsState extends ConsumerState<InternalJobs> {
  static const int bonusRate = 5; // 5% bonus

  /// tabs: 0 = incoming, 1 = active, 2 = completed
  int _selectedTab = 0;

  bool _isLoading = false;
  String? _errorMessage;

  List<InternalJob> _incomingJobs = [];
  List<InternalJob> _activeJobs = [];
  List<InternalJob> _completedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadAllJobs();
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ------------------------------------------------------
  // helpers
  // ------------------------------------------------------

  Color _priorityDotColor(JobPriority? priority) {
    switch (priority) {
      case JobPriority.high:
        return const Color(0xFFEF4444); // red-500
      case JobPriority.medium:
        return const Color(0xFFF59E0B); // yellow-500
      case JobPriority.low:
        return const Color(0xFF10B981); // green-500
      default:
        return const Color(0xFF6B7280); // gray-500
    }
  }

  double _calculateBonus(String payment) {
    final sanitized = payment.replaceAll('\$', '').replaceAll(',', '');
    final amount = double.tryParse(sanitized) ?? 0;
    return (amount * bonusRate) / 100;
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

  /// Determine payment button state for COMPLETED_PENDING_PAYMENT jobs
  /// Rules:
  /// 1. If payments is empty ([]) or null → show action: "Please submit payment"
  /// 2. If payments has at least one item with status == "PENDING_VERIFICATION" → 
  ///    disable payment submission and show: "Payment verifying" (cannot upload proof again)
  /// 3. If payments is not empty and there is NO "PENDING_VERIFICATION", and all existing 
  ///    payments are "REJECTED" → show action: "Resubmit payment"
  PaymentButtonState _getPaymentButtonState(InternalJob job) {
    // Only check for COMPLETED_PENDING_PAYMENT status
    if (job.status != JobStatus.completedPendingPayment) {
      return PaymentButtonState.none;
    }

    final payments = job.payments ?? [];
    
    // Rule 1: If payments is empty ([]) or null → show action: "Please submit payment"
    if (payments.isEmpty) {
      return PaymentButtonState.submit;
    }

    // Rule 2: If payments has at least one item with status == "PENDING_VERIFICATION" 
    // → disable payment submission and show: "Payment verifying" (cannot upload proof again)
    // IMPORTANT: Check PENDING_VERIFICATION FIRST (highest priority)
    final hasPendingVerification = payments.any((p) {
      final status = p.status.toUpperCase().trim();
      return status == 'PENDING_VERIFICATION';
    });
    
    if (hasPendingVerification) {
      return PaymentButtonState.verifying;
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

    // Default: If payments exist but don't match above conditions → Show "Please submit payment"
    return PaymentButtonState.submit;
  }

  void _handleJobUpdate(InternalJob updatedJob) {
    // Find the existing job to preserve payment/bonus if needed
    final existingJob = _activeJobs.firstWhere(
      (job) => job.id == updatedJob.id,
      orElse: () => updatedJob,
    );

    // Preserve payment and bonus if API response has $0.00
    final paymentToUse = updatedJob.payment == '\$0.00' ? existingJob.payment : updatedJob.payment;
    final bonusToUse = updatedJob.bonus == '\$0.00' ? existingJob.bonus : updatedJob.bonus;
    
    final finalUpdated = updatedJob.copyWith(
      payment: paymentToUse,
      bonus: bonusToUse,
    );

    // active list update + if completed, move to completed
    setState(() {
      _activeJobs = _activeJobs
          .map((job) => job.id == finalUpdated.id ? finalUpdated : job)
          .toList();

      if (finalUpdated.status == JobStatus.completed) {
        _completedJobs = [..._completedJobs, finalUpdated];
        _activeJobs = _activeJobs
            .where((job) => job.id != finalUpdated.id)
            .toList();
      }
    });
  }

  Future<void> _handleAcceptIncoming(InternalJob job) async {
    try {
      final updated = await TechnicianJobsApi.respondToWorkOrder(
        woId: job.id,
        action: 'ACCEPT',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('work_order_accepted'.tr()),
        ),
      );

      setState(() {
        _incomingJobs = _incomingJobs.where((j) => j.id != job.id).toList();
        // updated job now "assigned" or "in progress" → active list
        _activeJobs = [..._activeJobs, updated];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${'failed_to_accept_job'.tr()}: $e')));
    }
  }

  Future<void> _handleDeclineIncoming(InternalJob job) async {
    try {
      await TechnicianJobsApi.respondToWorkOrder(
        woId: job.id,
        action: 'DECLINE',
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('work_order_declined'.tr())));

      setState(() {
        _incomingJobs = _incomingJobs.where((j) => j.id != job.id).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${'failed_to_decline_job'.tr()}: $e')));
    }
  }

  // ------------------------------------------------------
  // build
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Listen for refresh triggers when this screen becomes visible
    ref.listen<int>(screenRefreshTriggerProvider, (previous, next) {
      final currentIndex = ref.read(bottomNavIndexProvider);
      final visibleIndex = ref.read(currentVisibleScreenIndexProvider);
      // Refresh if this is the jobs screen (index 1) and it's currently visible
      if (currentIndex == 1 && visibleIndex == 1) {
        _loadAllJobs();
      }
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            child: Column(
              children: [
                // ---------- Header ----------
                Container(
                  width: double.infinity,
                  height: 119.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF111827)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                    top: 24.h,
                    bottom: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      Text(
                        'My Jobs',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Manage your assigned work orders',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFD1D5DB),
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------- Content (একটাই Expanded) ----------
                Expanded(
                  child: _isLoading && _incomingJobs.isEmpty && _activeJobs.isEmpty && _completedJobs.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null && _incomingJobs.isEmpty && _activeJobs.isEmpty && _completedJobs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAllJobs,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 16.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTabs(),
                                SizedBox(height: 16.h),
                                if (_isLoading)
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.h),
                                    child: const Center(child: CircularProgressIndicator()),
                                  )
                                else if (_selectedTab == 0)
                                  _buildIncomingTab()
                                else if (_selectedTab == 1)
                                  _buildActiveTab()
                                else
                                  _buildCompletedTab(),
                                SizedBox(height: 24.h),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        // SizedBox(
        //   width: double.infinity,
        //   height: 40.h,
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: isInProgress
        //           ? const Color(0xFF2563EB)
        //           : const Color(0xFF111827),
        //       foregroundColor: Colors.white,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(14.r),
        //       ),
        //     ),
        //     onPressed: () async {
        //       if (isInProgress) {
        //         // 👉 Continue Job: details popup খুলবে
        //         await showDialog(
        //           context: context,
        //           barrierDismissible: true,
        //           builder: (_) => const Jobdetails(), // পরে চাইলে job পাস করবে
        //         );
        //         // এখানে চাইলে complete সফল হলে আবার reload করতে পারো
        //         // await _loadAllJobs();
        //       } else {
        //         // 👉 Start Job flow: প্রথমে GPS popup
        //         await showDialog(
        //           context: context,
        //           barrierDismissible: true,
        //           builder: (_) => const Gpscheckinpopup(),
        //         );
        //
        //         // এখন আপাতত job এর latitude/longitude দিয়ে start করছি
        //         final lat = job.latitude ?? 0;
        //         final lng = job.longitude ?? 0;
        //
        //         try {
        //           final updated = await TechnicianJobsApi.startWorkOrder(
        //             woId: job.id,
        //             lat: lat,
        //             lng: lng,
        //           );
        //           _handleJobUpdate(updated);
        //         } catch (e) {
        //           ScaffoldMessenger.of(context).showSnackBar(
        //             SnackBar(content: Text('Failed to start job: $e')),
        //           );
        //         }
        //       }
        //     },
        //     child: Text(
        //       isInProgress ? 'Continue Job' : 'Start Job',
        //       style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
        //     ),
        //   ),
        // ),

        // // Job workflow overlay (placeholder)
        // if (_selectedJob != null)
        //   InternalWorkflowOverlay(
        //     job: _selectedJob!,
        //     onClose: () => setState(() => _selectedJob = null),
        //     onJobUpdate: (job) {
        //       _handleJobUpdate(job);
        //       setState(() => _selectedJob = null);
        //     },
        //   ),
        //
        // // Incoming job detail overlay (placeholder)
        // // if (_selectedJobForDetails != null)
        // //   JobDetailOverlay(
        // //     job: _selectedJobForDetails!,
        // //     responseTimeLimitSeconds: 180,
        // //     onClose: () => setState(() => _selectedJobForDetails = null),
        // //     onAccept: () => _handleAcceptIncoming(_selectedJobForDetails!),
        // //     onDecline: () => _handleDeclineIncoming(_selectedJobForDetails!),
        // //   ),
        // if (_selectedJobForDetails != null)
        //   JobDetailOverlay(
        //     job: _selectedJobForDetails!,
        //     responseTimeLimitSeconds: 180,
        //     onClose: () => setState(() => _selectedJobForDetails = null),
        //     onAccept: () => _handleAcceptIncoming(_selectedJobForDetails!),
        //     onDecline: () => _handleDeclineIncoming(_selectedJobForDetails!),
        //   ),
      ],
    );
  }
  // tabs (Incoming / Active / Done)

  Widget _buildTabs() {
    final bgColor = Colors.white;
    final shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8.r,
        offset: Offset(0, 4.h),
      ),
    ];

    Widget buildTab({
      required String label,
      required int index,
      bool showCount = false,
      int? count,
      Color? activeColor,
    }) {
      final bool isActive = _selectedTab == index;
      final Color activeBg =
          activeColor ?? (index == 0 ? const Color(0xFFC20001) : Colors.black);
      final textColor = isActive ? Colors.white : const Color(0xFF4B5563);

      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedTab = index;
            });
          },
          child: Container(
            height: 40.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (showCount && (count ?? 0) > 0)
                  Positioned(
                    top: -6.h,
                    right: 22.w,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB111),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: const Color(0xFF111827),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: shadow,
      ),
      child: Row(
        children: [
          buildTab(
            label: 'Incoming',
            index: 0,
            showCount: true,
            count: _incomingJobs.length,
            activeColor: const Color(0xFFC20001),
          ),
          SizedBox(width: 4.w),
          buildTab(
            label: 'Active',
            index: 1,
            activeColor: const Color(0xFF111827),
          ),
          SizedBox(width: 4.w),
          buildTab(
            label: 'Done',
            index: 2,
            activeColor: const Color(0xFF111827),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  //  Incoming tab
  // ------------------------------------------------------

  Widget _buildIncomingTab() {
    if (_incomingJobs.isEmpty) {
      return _EmptyCard(
        icon: Icons.notifications_none_outlined,
        title: 'No incoming work orders',
        subtitle: 'Dispatcher will notify you when new jobs arrive',
      );
    }

    return Column(
      children: _incomingJobs.map((job) => _buildIncomingJobCard(job)).toList(),
    );
  }

  Widget _buildIncomingJobCard(InternalJob job) {
    final gradient = const LinearGradient(
      colors: [
        Color(0xFFFFF5F5), // red-50
        Color(0xFFFFF7ED), // orange-50
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: gradient,
        border: Border.all(
          color: const Color(0xFFC20001).withOpacity(0.2),
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active_outlined,
                            size: 16,
                            color: Color(0xFFC20001),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              job.title,
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (job.priority != null) ...[
                            SizedBox(width: 6.w),
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: _priorityDotColor(job.priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Customer: ${job.customer}',
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC20001),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        job.location,
                        style: TextStyle(
                          color: const Color(0xFF4B5563),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: Color(0xFF9CA3AF),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${job.date}${job.time != null ? ' at ${job.time}' : ''}',
                      style: TextStyle(
                        color: const Color(0xFF4B5563),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Job Payment',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            job.payment,
                            style: TextStyle(
                              color: const Color(0xFF111827),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Your Commission ($bonusRate%)',
                          style: TextStyle(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '\$${_calculateBonus(job.payment).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFF059669),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      // Show incoming job details dialog with Accept/Reject buttons
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => IncomingJobDetails(
                          job: job,
                          onAccept: () => _handleAcceptIncoming(job),
                          onReject: () => _handleDeclineIncoming(job),
                          bonusRate: bonusRate.toDouble(),
                        ),
                      );
                    },
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 13.sp,
                        // requested: black text
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC20001),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      // setState(() {
                      //   _selectedJobForDetails = job;
                      // });
                      _handleAcceptIncoming(job);
                    },
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------
  //  Active tab
  // ------------------------------------------------------

  Widget _buildActiveTab() {
    if (_activeJobs.isEmpty) {
      return _EmptyCard(
        icon: Icons.access_time,
        title: 'No active assignments',
        subtitle: "You'll be notified when jobs are assigned",
      );
    }

    return Column(
      children: _activeJobs.map((job) => _buildActiveJobCard(job)).toList(),
    );
  }

  Widget _buildActiveJobCard(InternalJob job) {
    final bool isInProgress = job.status == JobStatus.inProgress;

    final BoxDecoration decoration = isInProgress
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF5F7FF), Color(0xFFE5EDFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
          )
        : BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          );

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Container(
        decoration: decoration,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- header --------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: TextStyle(
                                  color: const Color(0xFF111827),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (job.priority != null) ...[
                              SizedBox(width: 6.w),
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: _priorityDotColor(job.priority),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Customer: ${job.customer}',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(job),
                ],
              ),
              SizedBox(height: 10.h),

              // -------- details --------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          job.location,
                          style: TextStyle(
                            color: const Color(0xFF4B5563),
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${job.date}${job.time != null ? ' at ${job.time}' : ''}',
                        style: TextStyle(
                          color: const Color(0xFF4B5563),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job Payment',
                              style: TextStyle(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              job.payment,
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Your Commission ($bonusRate%)',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '\$${_calculateBonus(job.payment).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: const Color(0xFF059669),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // -------- Payment button for COMPLETED_PENDING_PAYMENT jobs --------
              if (job.status == JobStatus.completedPendingPayment) ...[
                _buildPaymentStatusInfo(job),
                SizedBox(height: 8.h),
                _buildPaymentActionButton(job),
                SizedBox(height: 10.h),
              ],

              // -------- buttons (View Details + Start/Continue) --------
              // Hide Start/Continue buttons if payment is pending
              if (job.status != JobStatus.completedPendingPayment)
                if (isInProgress)
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () async {
                      // Continue Job -> details popup
                      await showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => Jobdetails(job: job),
                      );
                    },
                    child: Text(
                      'Continue Job',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        onPressed: () {
                          // View Details -> same as InternalDashboardV2Screen
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => Viewjobdetails(
                              job: job,
                              onJobUpdate: (updatedJob) => _handleJobUpdate(updatedJob),
                              bonusRate: bonusRate.toDouble(),
                            ),
                          );
                        },
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        onPressed: () async {
                          // Start Job flow (GPS popup -> Map screen -> API call)
                          await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => Gpscheckinpopup(
                              jobAddress: job.address ?? job.location,
                              onLocationVerified: (lat, lng) async {
                                // Location verified from map, now start the job
                                try {
                                  final updated = await TechnicianJobsApi.startWorkOrder(
                                    woId: job.id,
                                    lat: lat,
                                    lng: lng,
                                  );
                                  
                                  // Preserve payment and bonus if API response has $0.00
                                  final paymentToUse = updated.payment == '\$0.00' ? job.payment : updated.payment;
                                  final bonusToUse = updated.bonus == '\$0.00' ? job.bonus : updated.bonus;
                                  
                                  final finalUpdated = updated.copyWith(
                                    payment: paymentToUse,
                                    bonus: bonusToUse,
                                  );
                                  
                                  _handleJobUpdate(finalUpdated);
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('job_started_successfully'.tr()),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${'failed_to_start_job'.tr()}: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Start Job',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
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
    );
  }

  // ------------------------------------------------------
  //  Status Badge
  // ------------------------------------------------------

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
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case JobStatus.inProgress:
        backgroundColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
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
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ------------------------------------------------------
  //  Payment Status Info & Action Button
  // ------------------------------------------------------

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

  Widget _buildPaymentActionButton(InternalJob job) {
    final buttonState = _getPaymentButtonState(job);
    
    // Debug: Print payment state for troubleshooting
    // if (job.status == JobStatus.completedPendingPayment) {
    //   print('Job ${job.id} - Button State: $buttonState');
    //   print('  Payments: ${job.payments?.length ?? 0}');
    //   if (job.payments != null) {
    //     for (var p in job.payments!) {
    //       print('    Payment ${p.id}: status="${p.status}"');
    //     }
    //   }
    // }
    
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
        backgroundColor = const Color(0xFFC20001);
        break;
      case PaymentButtonState.verifying:
        buttonText = 'Payment verifying';
        isEnabled = false;
        backgroundColor = const Color(0xFF9CA3AF);
        break;
      case PaymentButtonState.resubmit:
        buttonText = 'Resubmit payment';
        isEnabled = true;
        backgroundColor = const Color(0xFFC20001);
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
          foregroundColor: Colors.white,
          disabledBackgroundColor: backgroundColor,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        onPressed: isEnabled
            ? () => _showPaymentSubmitDialog(job)
            : null,
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _showPaymentSubmitDialog(InternalJob job) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentSubmitBottomSheet(
        job: job,
        onPaymentSubmitted: () {
          _loadAllJobs(); // Refresh job list
        },
      ),
    );
  }

  // ------------------------------------------------------
  //  Completed tab
  // ------------------------------------------------------

  Widget _buildCompletedTab() {
    if (_completedJobs.isEmpty) {
      return _EmptyCard(
        icon: Icons.check_circle_outline,
        title: 'No completed jobs yet',
      );
    }

    return Column(
      children: _completedJobs
          .map((job) => _buildCompletedJobCard(job))
          .toList(),
    );
  }

  Widget _buildCompletedJobCard(InternalJob job) {
    final bonus = _calculateBonus(job.payment);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          color: const Color(0xFF111827),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Customer: ${job.customer}',
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Color(0xFF10B981),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    job.location,
                    style: TextStyle(
                      color: const Color(0xFF4B5563),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6.w),
                Text(
                  job.date,
                  style: TextStyle(
                    color: const Color(0xFF4B5563),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Payment',
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 11.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        job.payment,
                        style: TextStyle(
                          color: const Color(0xFF111827),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Commission Earned ($bonusRate%)',
                      style: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '\$${bonus.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: const Color(0xFF059669),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Small helper widgets
/// ------------------------------------------------------

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.w, color: const Color(0xFFD1D5DB)),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle!,
                style: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
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

    // Only require proof image for MOBILE_MONEY
    if (_selectedMethod != 'CASH' && _proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload proof image for mobile payment')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit payment: $e')),
        );
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Submit Payment',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
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
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    readOnly: true, // Make it read-only to prevent manual editing
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
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
                      fillColor: Colors.grey.shade50,
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
                  Text(
                    'Service price (auto-filled)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Method dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedMethod,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: const Icon(Icons.payment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'CASH',
                        child: Text('Cash'),
                      ),
                      DropdownMenuItem(
                        value: 'MOBILE_MONEY',
                        child: Text('Mobile Money (bKash/Nagad/Bank Transfer)'),
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

                  // Transaction Ref field (required only for MOBILE_MONEY)
                  TextFormField(
                    controller: _transactionRefController,
                    decoration: InputDecoration(
                      labelText: _selectedMethod == 'CASH' 
                          ? 'Transaction Reference (Optional)' 
                          : 'Transaction Reference',
                      hintText: _selectedMethod == 'CASH'
                          ? 'Enter transaction reference (optional)'
                          : 'Enter transaction reference',
                      prefixIcon: const Icon(Icons.receipt),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    validator: (value) {
                      // Transaction ref is required only for MOBILE_MONEY
                      if (_selectedMethod != 'CASH' && (value == null || value.trim().isEmpty)) {
                        return 'Transaction reference is required for mobile payment';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Proof image upload (only for MOBILE_MONEY)
                  if (_selectedMethod != 'CASH') ...[
                    Text(
                      'Proof Image *',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Required for mobile payments',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Proof Image',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Not required for cash payment',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _selectedMethod != 'CASH' ? _pickProofImage : null,
                    child: Opacity(
                      opacity: _selectedMethod == 'CASH' ? 0.5 : 1.0,
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
                                  color: const Color(0xFF9CA3AF),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  _selectedMethod == 'CASH'
                                      ? 'Not required for cash'
                                      : 'Tap to upload proof image',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Submit and Cancel buttons
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
                            backgroundColor: const Color(0xFFC20001),
                            foregroundColor: Colors.white,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

/// ------------------------------------------------------
///  PLACEHOLDER overlays for InternalWorkflow & JobDetail
/// ------------------------------------------------------

class InternalWorkflowOverlay extends StatelessWidget {
  const InternalWorkflowOverlay({
    super.key,
    required this.job,
    required this.onClose,
    required this.onJobUpdate,
  });

  final InternalJob job;
  final VoidCallback onClose;
  final void Function(InternalJob job) onJobUpdate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                job.title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                'InternalWorkflow placeholder.\nPore real workflow screen diye replace korben.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClose,
                      child: Text('close'.tr()),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onJobUpdate(job.copyWith(status: JobStatus.completed));
                      },
                      child: Text('mark_completed'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
