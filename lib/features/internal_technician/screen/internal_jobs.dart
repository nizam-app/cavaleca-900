import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workpleis/features/internal_technician/widget/newJobAssigned.dart';

import '../widget/jobDetails.dart';
import '../widget/job_detail-overlay.dart';
import '../widget/newJobAssignedPopup.dart';
///  Models

enum JobStatus { incoming, pending, accepted, inProgress, completed, assigned }

enum JobPriority { high, medium, low }

class Job {
  final int id;
  final String title;
  final String customer;
  final String? customerPhone;
  final String location;
  final String? address;
  final String date;
  final String? time;
  final String payment; // e.g. "$120"
  final String bonus; // e.g. "$6.00"
  final String? description;
  final String? category;
  final JobStatus status;
  final JobPriority? priority;
  final double? latitude;
  final double? longitude;

  const Job({
    required this.id,
    required this.title,
    required this.customer,
    this.customerPhone,
    required this.location,
    this.address,
    required this.date,
    this.time,
    required this.payment,
    required this.bonus,
    this.description,
    this.category,
    required this.status,
    this.priority,
    this.latitude,
    this.longitude,
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
    double? latitude,
    double? longitude,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

///  Screen

class InternalJobs extends StatefulWidget {
  const InternalJobs({super.key});

  static const String routeName = '/internal-jobs';

  @override
  State<InternalJobs> createState() => _InternalJobsState();
}

class _InternalJobsState extends State<InternalJobs> {
  static const int bonusRate = 5; // 5% bonus

  /// tabs: 0 = incoming, 1 = active, 2 = completed
  int _selectedTab = 0;

  Job? _selectedJob; // for workflow
  Job? _selectedJobForDetails; // for incoming detail modal

  late List<Job> _incomingJobs;
  late List<Job> _activeJobs;
  late List<Job> _completedJobs;

  @override
  void initState() {
    super.initState();

    // ------------------- mock data: incoming -------------------
    _incomingJobs = [
      Job(
        id: 10,
        title: 'Emergency Plumbing Repair',
        customer: 'Mariam Sy',
        customerPhone: '+222 45 67 89 01',
        location: 'Sebkha District',
        address: 'Building 15, Sebkha, Nouakchott',
        date: 'Nov 5, 2025',
        time: '6:00 PM',
        payment: '\$120',
        bonus: '\$6.00',
        description:
        'Urgent water leak in bathroom. Customer reports water damage spreading.',
        category: 'Plumbing',
        priority: JobPriority.high,
        status: JobStatus.pending,
      ),
      Job(
        id: -2025-0011,
        title: 'Emergency Plumbing Repair',
        customer: 'Ibrahim Kane',
        customerPhone: '+222 45 78 90 12',
        location: 'Tevragh Zeina',
        address: 'Avenue 8, Tevragh Zeina, Nouakchott',
        date: 'Nov 6, 2025',
        time: '9:00 AM',
        payment: '\$95',
        bonus: '\$4.75',
        description: 'Regular AC maintenance check and filter cleaning.',
        category: 'HVAC',
        priority: JobPriority.medium,
        status: JobStatus.pending,
      ),
    ];

    // ------------------- mock data: active -------------------
    _activeJobs = [
      Job(
        id: 1,
        title: 'HVAC System Maintenance',
        customer: 'Ahmed Mohammed',
        customerPhone: '+222 45 12 34 56',
        location: 'Tevragh Zeina District',
        address: 'Building 42, Tevragh Zeina, Nouakchott',
        date: 'Nov 5, 2025',
        time: '2:00 PM',
        payment: '\$180',
        bonus: '\$9.00',
        description:
        'Complete HVAC system maintenance and filter replacement.',
        category: 'HVAC',
        priority: JobPriority.high,
        status: JobStatus.inProgress,
      ),
      Job(
        id: 2,
        title: 'Electrical Safety Check',
        customer: 'Fatima Hassan',
        customerPhone: '+222 45 23 45 67',
        location: 'Ksar District',
        address: 'Rue 15, Ksar, Nouakchott',
        date: 'Nov 5, 2025',
        time: '4:30 PM',
        payment: '\$150',
        bonus: '\$7.50',
        description: 'Comprehensive electrical safety inspection.',
        category: 'Electrical',
        priority: JobPriority.medium,
        status: JobStatus.assigned,
      ),
    ];

    // ------------------- mock data: completed -------------------
    _completedJobs = [
      Job(
        id: 3,
        title: 'Plumbing Emergency Repair',
        customer: 'Omar Abdullah',
        customerPhone: '+222 45 34 56 78',
        location: 'Sebkha District',
        address: 'Avenue 20, Sebkha, Nouakchott',
        date: 'Nov 3, 2025',
        time: '10:00 AM',
        payment: '\$200',
        bonus: '\$10.00',
        description: 'Emergency pipe repair and leak detection.',
        category: 'Plumbing',
        status: JobStatus.completed,
      ),
      Job(
        id: 4,
        title: 'HVAC Installation',
        customer: 'Aminata Diallo',
        customerPhone: '+222 45 45 67 89',
        location: 'Tevragh Zeina',
        address: 'Building 28, Tevragh Zeina, Nouakchott',
        date: 'Nov 2, 2025',
        time: '11:30 AM',
        payment: '\$350',
        bonus: '\$17.50',
        description: 'New HVAC unit installation in residential building.',
        category: 'HVAC',
        status: JobStatus.completed,
      ),
      Job(
        id: 5,
        title: 'Electrical Panel Upgrade',
        customer: 'Sidi Mohamed',
        customerPhone: '+222 45 56 78 90',
        location: 'Arafat District',
        address: 'Street 12, Arafat, Nouakchott',
        date: 'Nov 1, 2025',
        time: '3:00 PM',
        payment: '\$280',
        bonus: '\$14.00',
        description: 'Electrical panel replacement and upgrade.',
        category: 'Electrical',
        status: JobStatus.completed,
      ),
    ];
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

  void _handleJobUpdate(Job updatedJob) {
    // active list update + if completed, move to completed
    setState(() {
      _activeJobs = _activeJobs
          .map((job) => job.id == updatedJob.id ? updatedJob : job)
          .toList();

      if (updatedJob.status == JobStatus.completed) {
        _completedJobs = [..._completedJobs, updatedJob];
        _activeJobs =
            _activeJobs.where((job) => job.id != updatedJob.id).toList();
      }
    });
  }

  void _handleAcceptIncoming(Job job) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Work order accepted! Moving to Active Jobs.'),
      ),
    );

    setState(() {
      _incomingJobs = _incomingJobs.where((j) => j.id != job.id).toList();
      _activeJobs = [
        ..._activeJobs,
        job.copyWith(
          status: JobStatus.assigned,
        ),
      ];
      _selectedJobForDetails = null;
    });
  }

  void _handleDeclineIncoming(Job job) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Work order declined. Notifying dispatcher.'),
      ),
    );

    setState(() {
      _incomingJobs = _incomingJobs.where((j) => j.id != job.id).toList();
      _selectedJobForDetails = null;
    });
  }

  // ------------------------------------------------------
  // build
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  height: 119.h,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1F2937), // gray-800
                        Color(0xFF111827), // gray-900
                      ],
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

                // Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTabs(),
                        SizedBox(height: 16.h),
                        if (_selectedTab == 0)
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
              ],
            ),
          ),
        ),

        // Job workflow overlay (placeholder)
        if (_selectedJob != null)
          InternalWorkflowOverlay(
            job: _selectedJob!,
            onClose: () => setState(() => _selectedJob = null),
            onJobUpdate: (job) {
              _handleJobUpdate(job);
              setState(() => _selectedJob = null);
            },
          ),

        // Incoming job detail overlay (placeholder)
        // if (_selectedJobForDetails != null)
        //   JobDetailOverlay(
        //     job: _selectedJobForDetails!,
        //     responseTimeLimitSeconds: 180,
        //     onClose: () => setState(() => _selectedJobForDetails = null),
        //     onAccept: () => _handleAcceptIncoming(_selectedJobForDetails!),
        //     onDecline: () => _handleDeclineIncoming(_selectedJobForDetails!),
        //   ),


        if (_selectedJobForDetails != null)
          JobDetailOverlay(
            job: _selectedJobForDetails!,
            responseTimeLimitSeconds: 180,
            onClose: () => setState(() => _selectedJobForDetails = null),
            onAccept: () => _handleAcceptIncoming(_selectedJobForDetails!),
            onDecline: () => _handleDeclineIncoming(_selectedJobForDetails!),
          ),
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

  Widget _buildIncomingJobCard(Job job) {
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                          'Your Bonus ($bonusRate%)',
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
                      // setState(() {
                      //   _selectedJobForDetails = job;
                      // });

                      // showDialog(
                      //   context: context,
                      //   barrierDismissible: true,
                      //   builder: (_) => JobDetailOverlay(),
                      // );

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
                      setState(() {
                        _selectedJobForDetails = job;
                      });

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

  Widget _buildActiveJobCard(Job job) {
    final bool isInProgress = job.status == JobStatus.inProgress;

    // requested: in-progress background ta aro white-ish, light gradient
    final BoxDecoration decoration = isInProgress
        ? BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFFF5F7FF), // very light
          Color(0xFFE5EDFF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(
        color: const Color(0xFFBFDBFE),
        width: 2,
      ),
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
                    padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isInProgress
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      isInProgress ? 'In Progress' : 'Assigned',
                      style: TextStyle(
                        color: isInProgress
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF92400E),
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
                            'Your Bonus ($bonusRate%)',
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
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInProgress
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () {
                    //this is the pop up of Continue and start button
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => Jobdetails() ,
                    );

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const NewJobAssignedPopup(),
                    );

                  },
                  child: Text(
                    isInProgress ? 'Continue Job' : 'Start Job',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
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
      children:
      _completedJobs.map((job) => _buildCompletedJobCard(job)).toList(),
    );
  }

  Widget _buildCompletedJobCard(Job job) {
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
                      'Bonus Earned ($bonusRate%)',
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
  const _EmptyCard({
    required this.icon,
    required this.title,
    this.subtitle,
  });

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
            Icon(
              icon,
              size: 48.w,
              color: const Color(0xFFD1D5DB),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 14.sp,
              ),
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

  final Job job;
  final VoidCallback onClose;
  final void Function(Job job) onJobUpdate;

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
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
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
                      child: const Text('Close'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onJobUpdate(
                          job.copyWith(status: JobStatus.completed),
                        );
                      },
                      child: const Text('Mark Completed'),
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

