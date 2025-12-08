

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/internal_technician/screen/job/logic/internal_job_logic.dart';
import 'package:workpleis/features/internal_technician/screen/job/model/internal_job_model.dart';
import 'package:workpleis/features/internal_technician/widget/jobDetails.dart';
import 'package:workpleis/features/internal_technician/widget/viewJobDetails.dart';
import 'package:workpleis/features/internal_technician/screen/dashboard/logic/technician_dashboard_api.dart';
import 'package:workpleis/features/internal_technician/screen/dashboard/model/technician_dashboard_model.dart';

import 'package:easy_localization/easy_localization.dart';

/// ------------------------------------------------------
///  Colors
/// ------------------------------------------------------
const Color kBg = Color(0xFFF4F4F4);
const Color kCard = Colors.white;
const Color kTextMain = Color(0xFF364153);
const Color kTextMuted = Color(0xFF9CA3AF);
const Color kPrimaryYellow = Color(0xFFE69F0F);
const Color kPrimaryYellowDark = Color(0xFFE69F0F);
const Color kPrimaryBlue = Color(0xFF2563EB);
const Color kInProgressBg = Color(0xFFE3F0FF);

/// ------------------------------------------------------
///  Tabs – active / completed
/// ------------------------------------------------------
enum JobsTab { active, completed }

final jobsTabProvider = StateProvider<JobsTab>((ref) => JobsTab.active);

/// ------------------------------------------------------
///  Freelancers Home Screen
/// ------------------------------------------------------
class FreelancerHomeScreen extends ConsumerStatefulWidget {
  const FreelancerHomeScreen({super.key});

  static const routeName = '/freelancer-home';

  @override
  ConsumerState<FreelancerHomeScreen> createState() =>
      _FreelancerHomeScreenState();
}

class _FreelancerHomeScreenState extends ConsumerState<FreelancerHomeScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  List<InternalJob> _activeJobs = [];
  List<InternalJob> _completedJobs = [];
  TechnicianDashboardModel? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Dashboard data fetch
      final dashboardData = await TechnicianDashboardApi.fetchDashboard();
      
      // same backend function
      final active = await TechnicianJobsApi.fetchJobs('active');
      final done = await TechnicianJobsApi.fetchJobs('done');

      setState(() {
        _dashboardData = dashboardData;
        _activeJobs = active;
        _completedJobs = done;
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

  double _parseMoney(String money) {
    final cleaned = money.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  double get _monthlyCommission =>
      _completedJobs.fold(0.0, (sum, j) => sum + _parseMoney(j.bonus));

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(jobsTabProvider);

    final inProgressJobs = _activeJobs
        .where((j) => j.status == JobStatus.inProgress)
        .toList();
    final acceptedJobs = _activeJobs
        .where((j) => j.status == JobStatus.assigned)
        .toList();

    // Use API data if available, otherwise fallback to calculated values
    final completedCount = _dashboardData?.completedThisMonth ?? _completedJobs.length;
    final activeCount = _dashboardData?.activeJobs ?? (inProgressJobs.length + acceptedJobs.length);
    final inProgressCount = _dashboardData?.inProgress ?? inProgressJobs.length;
    final readyToStartCount = _dashboardData?.readyToStart ?? acceptedJobs.length;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadJobs,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderSection(
                  monthlyCommission: (_dashboardData?.thisWeekEarned ?? 0).toDouble(),
                  completedJobsThisMonth: completedCount,
                  userName: 'freelancer_tech'.tr(),
                ),
                SizedBox(height: 12.h),
                _StatsRow(
                  active: readyToStartCount,
                  inProgress: inProgressCount,
                  completedThisMonth: completedCount,
                ),
                SizedBox(height: 16.h),
                _TabSwitcher(
                  activeCount: activeCount,
                  completedCount: completedCount,
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: tab == JobsTab.active
                      ? _ActiveJobsSection(
                          inProgressJobs: inProgressJobs,
                          acceptedJobs: acceptedJobs,
                        )
                      : _CompletedJobsSection(completedJobs: _completedJobs),
                ),
                SizedBox(height: 16.h),
                const _TopPerformerCard(),
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
class _HeaderSection extends StatelessWidget {
  final String userName;
  final double monthlyCommission;
  final int completedJobsThisMonth;

  const _HeaderSection({
    required this.userName,
    required this.monthlyCommission,
    required this.completedJobsThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 18.h,
        bottom: 18.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryYellow, kPrimaryYellowDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $userName',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'ready_earn_today'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 44.w,
                width: 44.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logoicon.png',
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Commission (15%)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '\$${monthlyCommission.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.brown.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'November 2025',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.brown.shade900.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '$completedJobsThisMonth jobs completed',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
///  Stats Row (3 cards)
/// ------------------------------------------------------
class _StatsRow extends StatelessWidget {
  final int active;
  final int inProgress;
  final int completedThisMonth;

  const _StatsRow({
    required this.active,
    required this.inProgress,
    required this.completedThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.work_outline,
              iconBg: const Color(0xFFFFF4D7),
              iconColor: const Color(0xFFE6A400),
              value: active.toString(),
              label: 'Ready to start',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              icon: Icons.access_time,
              iconBg: const Color(0xFFE5F1FF),
              iconColor: kPrimaryBlue,
              value: inProgress.toString(),
              label: 'Active now',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              iconBg: const Color(0xFFE7F9ED),
              iconColor: const Color(0xFF16A34A),
              value: completedThisMonth.toString(),
              label: 'This month',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32.w,
            width: 32.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: iconColor),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: kTextMain,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: kTextMuted),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
///  Tabs (Active / Completed)
/// ------------------------------------------------------
class _TabSwitcher extends ConsumerWidget {
  final int activeCount;
  final int completedCount;

  const _TabSwitcher({required this.activeCount, required this.completedCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(jobsTabProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(24.r),
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
                label: 'Active ($activeCount)',
                selected: tab == JobsTab.active,
                onTap: () =>
                    ref.read(jobsTabProvider.notifier).state = JobsTab.active,
              ),
            ),
            Expanded(
              child: _TabChip(
                label: 'Completed ($completedCount)',
                selected: tab == JobsTab.completed,
                onTap: () => ref.read(jobsTabProvider.notifier).state =
                    JobsTab.completed,
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
          color: selected ? kPrimaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : kTextMain,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Active Jobs Section
/// ------------------------------------------------------
class _ActiveJobsSection extends StatelessWidget {
  final List<InternalJob> inProgressJobs;
  final List<InternalJob> acceptedJobs;

  const _ActiveJobsSection({
    required this.inProgressJobs,
    required this.acceptedJobs,
  });

  @override
  Widget build(BuildContext context) {
    if (inProgressJobs.isEmpty && acceptedJobs.isEmpty) {
      return Center(
        child: Text(
          'no_completed_jobs_yet'.tr(),
          style: TextStyle(fontSize: 13.sp, color: kTextMuted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (inProgressJobs.isNotEmpty) ...[
          _SectionTitle(
            icon: Icons.access_time,
            label: 'in_progress'.tr(),
          ),
          SizedBox(height: 6.h),
          for (final job in inProgressJobs)
            _JobCard(job: job, isInProgressCard: true),
          SizedBox(height: 16.h),
        ],
        if (acceptedJobs.isNotEmpty) ...[
          _SectionTitle(
            icon: Icons.work_outline,
            label: 'ready_start'.tr(),
          ),
          SizedBox(height: 6.h),
          for (final job in acceptedJobs)
            _JobCard(job: job, isInProgressCard: false),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: kTextMuted),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: kTextMuted,
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------
///  Single Job Card (InternalJob based)
/// ------------------------------------------------------
class _JobCard extends ConsumerWidget {
  final InternalJob job;
  final bool isInProgressCard;

  const _JobCard({required this.job, required this.isInProgressCard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = isInProgressCard ? kInProgressBg : kCard;
    final borderColor = isInProgressCard
        ? kPrimaryBlue.withOpacity(0.3)
        : Colors.transparent;
    final isInProgress = job.status == JobStatus.inProgress;

    final address = job.address ?? job.location;
    final dateLabel = '${job.date}${job.time != null ? ' at ${job.time}' : ''}';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: borderColor,
          width: isInProgressCard ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title & payment
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
                        color: kTextMain,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.category ?? '',
                      style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    job.payment,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: kTextMain,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Earn ${job.bonus}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // address & time
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14.sp, color: kTextMuted),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 12.sp, color: kTextMain),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14.sp,
                color: kTextMuted,
              ),
              SizedBox(width: 4.w),
              Text(
                dateLabel,
                style: TextStyle(fontSize: 12.sp, color: kTextMain),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusBadge(
                label: isInProgressCard ? 'In Progress' : 'Ready to Start',
                color: isInProgressCard
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE6A400),
                bgColor: isInProgressCard
                    ? const Color(0xFFE5F1FF)
                    : const Color(0xFFFFF4D7),
              ),
              SizedBox(
                height: 32.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isInProgressCard
                        ? const Color(0xFF2563EB)
                        : kPrimaryYellow,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (isInProgress) {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => Jobdetails(job: job),
                        );
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => Viewjobdetails(
                            job: job,
                            bonusRate: 5.0,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: Text(
                      isInProgressCard ? 'Continue' : 'View Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
///  Completed Jobs Section
/// ------------------------------------------------------
class _CompletedJobsSection extends StatelessWidget {
  final List<InternalJob> completedJobs;

  const _CompletedJobsSection({required this.completedJobs});

  @override
  Widget build(BuildContext context) {
    if (completedJobs.isEmpty) {
      return Center(
        child: Text(
          'no_completed_jobs_yet'.tr(),
          style: TextStyle(fontSize: 14.sp, color: kTextMuted),
        ),
      );
    }

    return Column(
      children: [
        for (final job in completedJobs)
          Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: kTextMain,
                        ),
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Customer: ${job.customer}',
                  style: TextStyle(fontSize: 12.sp, color: kTextMuted),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: kTextMuted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      job.date,
                      style: TextStyle(fontSize: 12.sp, color: kTextMain),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.sp,
                      color: kTextMuted,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        job.address ?? job.location,
                        style: TextStyle(fontSize: 12.sp, color: kTextMain),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Divider(color: kTextMuted, height: 1.h),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'commission_earned '.tr(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: kTextMuted,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          job.bonus,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F9ED),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Paid',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF16A34A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// ------------------------------------------------------
///  Top Performer Card
/// ------------------------------------------------------
class _TopPerformerCard extends StatelessWidget {
  const _TopPerformerCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF4EAFF), Color(0xFFFEE7F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 44.w,
              width: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE9D5FF),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Color(0xFF7C3AED),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'top_performer'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: kTextMain,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'keep_up_great_work'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.trending_up, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }
}
