import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workpleis/features/internal_technician/screen/job/logic/internal_job_logic.dart';
import 'package:workpleis/features/internal_technician/screen/job/model/internal_job_model.dart';
import 'package:workpleis/features/internal_technician/widget/jobDetails.dart';
import 'package:workpleis/features/internal_technician/widget/viewJobDetails.dart';
import 'package:workpleis/features/internal_technician/screen/dashboard/logic/technician_dashboard_api.dart';
import 'package:workpleis/features/internal_technician/screen/dashboard/model/technician_dashboard_model.dart';
import 'package:workpleis/core/widget/screen_refresh_provider.dart';
import 'package:workpleis/features/nav_bar/logic/botton_nav_index_logic.dart';

class InternalDashboardV2Screen extends ConsumerStatefulWidget {
  const InternalDashboardV2Screen({super.key, this.userName = 'Sarah'});

  static const String routeName = '/internal-dashboard';

  final String userName;

  @override
  ConsumerState<InternalDashboardV2Screen> createState() =>
      _InternalDashboardV2ScreenState();
}

class _InternalDashboardV2ScreenState extends ConsumerState<InternalDashboardV2Screen> {
  static const int bonusPercentage = 5; // 5% bonus on verified jobs

  bool _isLoading = false;
  String? _errorMessage;

  /// API theke ashbe
  List<InternalJob> _activeJobs = []; // assigned + in_progress
  List<InternalJob> _completedJobs = []; // completed
  TechnicianDashboardModel? _dashboardData;

  /// 0 = Active, 1 = Completed
  int activeTabIndex = 0;

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
      
      // আগের মতোই same API usage
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

  // ------------------------------------------------------
  //  Helpers
  // ------------------------------------------------------

  double _calculateBonus(String payment) {
    final sanitized = payment.replaceAll('\$', '').replaceAll(',', '');
    final paymentAmount = double.tryParse(sanitized) ?? 0;
    return (paymentAmount * bonusPercentage) / 100;
  }

  /// Assigned / Ready jobs = active but not inProgress / completed
  int get _openJobs => _activeJobs
      .where(
        (j) =>
            j.status != JobStatus.inProgress && j.status != JobStatus.completed,
      )
      .length;

  int get _inProgressJobs =>
      _activeJobs.where((j) => j.status == JobStatus.inProgress).length;

  /// Prefer locally fetched lists for counts; fall back to dashboard numbers.
  int get _uiActiveCount =>
      _activeJobs.isNotEmpty ? _activeJobs.length : (_dashboardData?.activeJobs ?? 0);

  int get _uiCompletedCount {
    final paidVerifiedCount = _completedJobs
        .where((job) => job.status == JobStatus.paidVerified)
        .length;
    return paidVerifiedCount > 0
        ? paidVerifiedCount
        : (_dashboardData?.completedThisMonth ?? 0);
  }

  double get _totalBonus =>
      _completedJobs.fold(0, (sum, job) => sum + _calculateBonus(job.payment));

  double get _weeklyBonus => _activeJobs
      .where(
        (j) =>
            j.status == JobStatus.inProgress || j.status != JobStatus.completed,
      )
      .fold(0, (sum, job) => sum + _calculateBonus(job.payment));

  void _handleJobUpdate(InternalJob updatedJob) {
    setState(() {
      _activeJobs = _activeJobs
          .map((job) => job.id == updatedJob.id ? updatedJob : job)
          .toList();

      if (updatedJob.status == JobStatus.completed) {
        _completedJobs = [..._completedJobs, updatedJob];
        _activeJobs = _activeJobs.where((j) => j.id != updatedJob.id).toList();
      }
    });
  }

  // ------------------------------------------------------
  //  UI
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Listen for refresh triggers when this screen becomes visible
    ref.listen<int>(screenRefreshTriggerProvider, (previous, next) {
      final currentIndex = ref.read(bottomNavIndexProvider);
      final visibleIndex = ref.read(currentVisibleScreenIndexProvider);
      // Refresh if this is the home screen (index 0) and it's currently visible
      if (currentIndex == 0 && visibleIndex == 0) {
        _loadJobs();
      }
    });

    final dashboard = _dashboardData;
    final stats = [
      _DashboardStat(
        label: 'This Week',
        value: '\$${dashboard != null ? dashboard.thisWeekBonus.toString() : _weeklyBonus.toStringAsFixed(0)}',
        icon: Icons.attach_money,
        iconBg: const Color(0xFFE0ECFF),
        iconColor: const Color(0xFF2563EB),
        subtext: 'Weekly bonus',
      ),
      _DashboardStat(
        label: 'Total Earned',
        value: '\$${dashboard != null ? dashboard.totalEarned.toString() : _totalBonus.toStringAsFixed(0)}',
        icon: Icons.trending_up,
        iconBg: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF059669),
        subtext: 'All bonuses',
      ),
      _DashboardStat(
        label: 'Active Jobs',
        value: _uiActiveCount.toString(),
        icon: Icons.work_outline,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFF59E0B),
        subtext: 'Assigned',
      ),
      _DashboardStat(
        label: 'Completed',
        value: _uiCompletedCount.toString(),
        icon: Icons.check_circle_outline,
        iconBg: const Color(0xFFEDE9FE),
        iconColor: const Color(0xFF7C3AED),
        subtext: 'This month',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- Header ----------------
            _buildHeader(theme),

            // --------------- Content ----------------
            Expanded(
              child: _isLoading
? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadJobs,
                      color: const Color(0xFFC20001),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Stats grid
                            _buildStatsGrid(stats),
                            const SizedBox(height: 16),
                            // Tabs (Active / Completed)
                            _buildTabs(),
                            const SizedBox(height: 16),
                            // Tab content
                            if (activeTabIndex == 0)
                              _buildActiveJobsSection()
                            else
                              _buildCompletedJobsSection(),
                            const SizedBox(height: 16),
                            // Performance card
                            _buildPerformanceCard(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC20001), Color(0xFF9A0001)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${widget.userName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Internal Technician',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
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
          const SizedBox(height: 16),
          // Quick Overview
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "This Week's Bonus",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_dashboardData != null ? _dashboardData!.thisWeekBonus.toString() : _weeklyBonus.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jobs Today',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (_dashboardData?.jobsToday ?? (_inProgressJobs + _openJobs)).toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(List<_DashboardStat> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(stat: stats[0])),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(stat: stats[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(stat: stats[2])),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(stat: stats[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final totalActive = _uiActiveCount;
    final completed = _uiCompletedCount;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => activeTabIndex = 0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: activeTabIndex == 0
                      ? const Color(0xFFC20001)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Active ($totalActive)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: activeTabIndex == 0
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => activeTabIndex = 1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: activeTabIndex == 1
                      ? const Color(0xFFC20001)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Completed ($completed)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: activeTabIndex == 1
                        ? Colors.white
                        : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  //  Active tab: In Progress + Assigned lists
  // ------------------------------------------------------

  Widget _buildActiveJobsSection() {
    if (_activeJobs.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work_outline, size: 40, color: Color(0xFFD1D5DB)),
              SizedBox(height: 8),
              Text(
                'No active jobs assigned',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                "You'll be notified when new jobs are assigned",
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final inProgressJobs = _activeJobs
        .where((j) => j.status == JobStatus.inProgress)
        .toList();

    final assignedJobs = _activeJobs
        .where(
          (j) =>
              j.status != JobStatus.inProgress &&
              j.status != JobStatus.completed,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (inProgressJobs.isNotEmpty) ...[
          const Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Color(0xFF4B5563)),
              SizedBox(width: 6),
              Text(
                'In Progress',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: inProgressJobs
                .map((job) => _buildJobCard(job: job))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (assignedJobs.isNotEmpty) ...[
          const Row(
            children: [
              Icon(Icons.work_outline, size: 16, color: Color(0xFF4B5563)),
              SizedBox(width: 6),
              Text(
                'Assigned Jobs',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: assignedJobs
                .map((job) => _buildJobCard(job: job))
                .toList(),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------
  //  Completed tab
  // ------------------------------------------------------

  Widget _buildCompletedJobsSection() {
    // Filter to show only PAID_VERIFIED jobs
    final paidVerifiedJobs = _completedJobs
        .where((job) => job.status == JobStatus.paidVerified)
        .toList();

    if (paidVerifiedJobs.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 40,
                color: Color(0xFFD1D5DB),
              ),
              SizedBox(height: 8),
              Text(
                'No completed jobs yet',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Your completed work will appear here',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: paidVerifiedJobs
          .map((job) => _buildCompletedJobCard(job: job))
          .toList(),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F3FF), Color(0xFFFDF2F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 26,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Excellent Performance',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_uiCompletedCount} jobs completed this month',
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.trending_up, size: 26, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------
  //  Card builders
  // ------------------------------------------------------

  Widget _buildJobCard({required InternalJob job}) {
    final isInProgress = job.status == JobStatus.inProgress;

    final gradientDecoration = isInProgress
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.4),
          )
        : BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          );

    final bool isHighPriority = job.priority == JobPriority.high;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: gradientDecoration.copyWith(
          boxShadow: isHighPriority
              ? [
                  BoxShadow(
                    color: const Color(0xFFFEE2E2).withOpacity(0.8),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : gradientDecoration.boxShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title + priority badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (job.priority != null) ...[
                              const SizedBox(width: 8),
                              _PriorityBadge(priority: job.priority!),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.category ?? '',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // address & date
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
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          job.address ?? job.location,
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${job.date}${job.time != null ? ' at ${job.time}' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // status badge + bonus + button
              Row(
                children: [
                  _StatusBadge(status: job.status),
                  const SizedBox(width: 8),
                  Text(
                    '+\$${_calculateBonus(job.payment).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      // Continue and View Details Button;
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
                              onJobUpdate: (updatedJob) => _handleJobUpdate(updatedJob),
                              bonusRate: bonusPercentage.toDouble(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: isInProgress
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFC20001),
                        elevation: 0,
                      ),
                      child: Text(
                        isInProgress ? 'Continue' : 'View',
                        style: const TextStyle(
                          fontSize: 13,
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

  Widget _buildCompletedJobCard({required InternalJob job}) {
    final bonus = _calculateBonus(job.payment);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title + check icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer: ${job.customer}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
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
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  job.date,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    job.address ?? job.location,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Earned ($bonusPercentage%)',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${bonus.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (job.priority == JobPriority.high)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Priority Completed',
                      style: TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
}

/// ------------------------------------------------------
///  Small UI helpers
/// ------------------------------------------------------

class _DashboardStat {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String subtext;

  _DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.subtext,
  });
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: stat.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(stat.icon, size: 20, color: stat.iconColor),
            ),
            const SizedBox(height: 10),
            Text(
              stat.label,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              stat.value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stat.subtext,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final JobPriority priority;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;
    IconData? icon;

    switch (priority) {
      case JobPriority.high:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        label = 'URGENT';
        icon = Icons.error_outline;
        break;
      case JobPriority.medium:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFF92400E);
        label = 'Medium';
        break;
      case JobPriority.low:
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF047857);
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case JobStatus.assigned:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFF92400E);
        label = 'Ready';
        break;
      case JobStatus.inProgress:
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1D4ED8);
        label = 'In Progress';
        break;
      case JobStatus.completed:
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF047857);
        label = 'Completed';
        break;
      default:
        bg = const Color(0xFFE5E7EB);
        text = const Color(0xFF4B5563);
        label = 'Status';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
