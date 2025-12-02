import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workpleis/features/internal_technician/widget/compliteJob.dart';
import 'package:workpleis/features/internal_technician/widget/jobDetails.dart';
import 'package:workpleis/features/internal_technician/widget/viewJobDetails.dart';

/// ------------------------------------------------------
///  Models
/// ------------------------------------------------------

enum JobStatus { assigned, accepted, inProgress, completed }

enum JobPriority { low, medium, high }

class Job {
  final int id;
  final String title;
  final String customer;
  final String customerPhone;
  final String location;
  final String address;
  final String date;
  final String time;
  final String payment; // example: "$150"
  final String bonus;   // example: "$25" (optional, now unused in calc)
  final String description;
  final String category;
  final JobStatus status;
  final JobPriority? priority;

  const Job({
    required this.id,
    required this.title,
    required this.customer,
    required this.customerPhone,
    required this.location,
    required this.address,
    required this.date,
    required this.time,
    required this.payment,
    required this.bonus,
    required this.description,
    required this.category,
    required this.status,
    this.priority,
  });

  Job copyWith({
    int? id,
    String? title,
    String? customer,
    String? customerPhone,
    String? location,
    String? address,
    String? date,
    String? time,
    String? payment,
    String? bonus,
    String? description,
    String? category,
    JobStatus? status,
    JobPriority? priority,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      customer: customer ?? this.customer,
      customerPhone: customerPhone ?? this.customerPhone,
      location: location ?? this.location,
      address: address ?? this.address,
      date: date ?? this.date,
      time: time ?? this.time,
      payment: payment ?? this.payment,
      bonus: bonus ?? this.bonus,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}

/// ------------------------------------------------------
///  Screen
/// ------------------------------------------------------

class InternalDashboardV2Screen extends StatefulWidget {
  const InternalDashboardV2Screen({
    super.key,
    this.userName = 'Sarah',
  });

  static const String routeName = '/internal-dashboard';

  final String userName;

  @override
  State<InternalDashboardV2Screen> createState() =>
      _InternalDashboardV2ScreenState();
}

class _InternalDashboardV2ScreenState extends State<InternalDashboardV2Screen> {
  static const int bonusPercentage = 5; // 5% bonus on verified jobs

  // active + in-progress jobs (mock data)
  late List<Job> jobs;
  // completed jobs (mock data)
  late List<Job> completedJobs;

  Job? selectedJob;

  /// 0 = Active, 1 = Completed
  int activeTabIndex = 0;

  @override
  void initState() {
    super.initState();

    // ------------------------------
    // Mock data (same as TSX)
    // ------------------------------
    jobs = [
      Job(
        id: 1,
        title: 'HVAC Emergency Repair',
        customer: 'Michael Johnson',
        customerPhone: '+1 234 567 8900',
        location: '2.3 km away',
        address: '123 Main St, Apt 4B',
        date: 'Today',
        time: '2:00 PM',
        payment: '\$150',
        bonus: '\$25',
        description: 'Emergency AC unit repair - system not cooling',
        category: 'HVAC Services',
        status: JobStatus.inProgress,
        priority: JobPriority.high,
      ),
      Job(
        id: 2,
        title: 'Electrical Installation',
        customer: 'Sarah Williams',
        customerPhone: '+1 234 567 8901',
        location: '1.8 km away',
        address: '456 Oak Ave, Suite 12',
        date: 'Today',
        time: '4:00 PM',
        payment: '\$120',
        bonus: '\$15',
        description: 'Install new electrical outlets in office space',
        category: 'Electrical Services',
        status: JobStatus.accepted,
        priority: JobPriority.medium,
      ),
      Job(
        id: 3,
        title: 'Plumbing Maintenance',
        customer: 'David Brown',
        customerPhone: '+1 234 567 8902',
        location: '3.5 km away',
        address: '789 Pine Street',
        date: 'Tomorrow',
        time: '10:00 AM',
        payment: '\$95',
        bonus: '\$10',
        description: 'Routine plumbing inspection and maintenance',
        category: 'Plumbing Services',
        status: JobStatus.accepted,
        priority: JobPriority.low,
      ),
    ];

    completedJobs = [
      Job(
        id: 4,
        title: 'HVAC Installation',
        customer: 'Emily Davis',
        customerPhone: '+1 234 567 8903',
        location: 'Downtown',
        address: '321 Elm Road',
        date: 'Nov 3, 2025',
        time: '9:00 AM',
        payment: '\$300',
        bonus: '\$40',
        description: 'New AC unit installation',
        category: 'HVAC Services',
        status: JobStatus.completed,
        priority: JobPriority.high,
      ),
      Job(
        id: 5,
        title: 'Electrical Inspection',
        customer: 'Robert Miller',
        customerPhone: '+1 234 567 8904',
        location: 'Northside',
        address: '654 Maple Drive',
        date: 'Nov 2, 2025',
        time: '1:00 PM',
        payment: '\$130',
        bonus: '\$15',
        description: 'Safety inspection of electrical panel',
        category: 'Electrical Services',
        status: JobStatus.completed,
        priority: JobPriority.medium,
      ),
      Job(
        id: 6,
        title: 'Plumbing Repair',
        customer: 'Jennifer Wilson',
        customerPhone: '+1 234 567 8905',
        location: 'Westside',
        address: '987 Cedar Lane',
        date: 'Nov 1, 2025',
        time: '11:00 AM',
        payment: '\$110',
        bonus: '\$12',
        description: 'Water heater repair',
        category: 'Plumbing Services',
        status: JobStatus.completed,
        priority: JobPriority.high,
      ),
    ];
  }

  // ------------------------------------------------------
  //  Helpers
  // ------------------------------------------------------

  double _calculateBonus(String payment) {
    final sanitized = payment.replaceAll('\$', '').replaceAll(',', '');
    final paymentAmount = double.tryParse(sanitized) ?? 0;
    return (paymentAmount * bonusPercentage) / 100;
  }

  int get _openJobs =>
      jobs.where((j) => j.status == JobStatus.accepted).length;

  int get _inProgressJobs =>
      jobs.where((j) => j.status == JobStatus.inProgress).length;

  int get _completedCount => completedJobs.length;

  double get _totalBonus => completedJobs.fold(
    0,
        (sum, job) => sum + _calculateBonus(job.payment),
  );

  double get _weeklyBonus => jobs
      .where(
        (j) => j.status == JobStatus.inProgress || j.status == JobStatus.accepted,
  )
      .fold(0, (sum, job) => sum + _calculateBonus(job.payment));

  void _handleJobUpdate(Job updatedJob) {
    setState(() {
      jobs = jobs
          .map((job) => job.id == updatedJob.id ? updatedJob : job)
          .toList();
    });
  }

  // ------------------------------------------------------
  //  UI
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final stats = [
      _DashboardStat(
        label: 'This Week',
        value: '\$${_weeklyBonus.toStringAsFixed(0)}',
        icon: Icons.attach_money,
        iconBg: const Color(0xFFE0ECFF),
        iconColor: const Color(0xFF2563EB),
        subtext: 'Weekly bonus',
      ),
      _DashboardStat(
        label: 'Total Earned',
        value: '\$${_totalBonus.toStringAsFixed(0)}',
        icon: Icons.trending_up,
        iconBg: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF059669),
        subtext: 'All bonuses',
      ),
      _DashboardStat(
        label: 'Active Jobs',
        value: (_openJobs + _inProgressJobs).toString(),
        icon: Icons.work_outline,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFF59E0B),
        subtext: 'Assigned',
      ),
      _DashboardStat(
        label: 'Completed',
        value: _completedCount.toString(),
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
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            // ---------------- TODO: Workflow modal / screen ----------------
            // React code e InternalWorkflow overlay chilo.
            // Pore tumi alada TSX diye dile ami seta alada screen/Modal hishebe
            // convert kore dibo, ebong ekhane use korbo.
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFC20001),
            Color(0xFF9A0001),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 16,
      ),
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
                    // width: 36,
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        '\$${_weeklyBonus.toStringAsFixed(0)}',
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        (_inProgressJobs + _openJobs).toString(),
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
    final totalActive = _openJobs + _inProgressJobs;
    final completed = _completedCount;

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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildActiveJobsSection() {
    if (jobs.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.work_outline,
                size: 40,
                color: Color(0xFFD1D5DB),
              ),
              SizedBox(height: 8),
              Text(
                'No active jobs assigned',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "You'll be notified when new jobs are assigned",
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final inProgressJobs =
    jobs.where((j) => j.status == JobStatus.inProgress).toList();
    final acceptedJobs =
    jobs.where((j) => j.status == JobStatus.accepted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (inProgressJobs.isNotEmpty) ...[
          Row(
            children: const [
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
        if (acceptedJobs.isNotEmpty) ...[
          Row(
            children: const [
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
            children:
            acceptedJobs.map((job) => _buildJobCard(job: job)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedJobsSection() {
    if (completedJobs.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle_outline,
                size: 40,
                color: Color(0xFFD1D5DB),
              ),
              SizedBox(height: 8),
              Text(
                'No completed jobs yet',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your completed work will appear here',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: completedJobs
          .map(
            (job) => _buildCompletedJobCard(job: job),
      )
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
            colors: [
              Color(0xFFF5F3FF),
              Color(0xFFFDF2F8),
            ],
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
                    '$_completedCount jobs completed this month',
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.trending_up,
              size: 26,
              color: Color(0xFF7C3AED),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------
  //  Card builders
  // ------------------------------------------------------

  Widget _buildJobCard({required Job job}) {
    final isInProgress = job.status == JobStatus.inProgress;

    final gradientDecoration = isInProgress
        ? BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFFEFF6FF),
          Color(0xFFDBEAFE),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: const Color(0xFFBFDBFE),
        width: 1.4,
      ),
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
              color: const Color(0xFEEBEB).withOpacity(0.8),
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
                          job.category,
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
                          job.address,
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
                        '${job.date} at ${job.time}',
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

                        onPressed: () {
                          if (isInProgress) {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => Jobdetails(),
                            );
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => Viewjobdetails(),
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

  Widget _buildCompletedJobCard({required Job job}) {
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
                    job.address,
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
                      'Bonus Earned ($bonusPercentage%)',
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
                        horizontal: 10, vertical: 4),
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
              child: Icon(
                stat.icon,
                size: 20,
                color: stat.iconColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              stat.label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
              ),
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
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
              ),
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
      case JobStatus.accepted:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFF92400E);
        label = 'Ready';
        break;
      case JobStatus.inProgress:
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1D4ED8);
        label = 'In Progress';
        break;
      default:
      // other statuses not shown on active list
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
