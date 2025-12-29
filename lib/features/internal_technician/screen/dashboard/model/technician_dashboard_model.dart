class TechnicianDashboardModel {
  final int thisWeekBonus;
  final int jobsToday;
  final int thisWeekEarned;
  final int totalEarned;
  final int activeJobs;
  final int completedThisMonth;
  final int inProgress;
  final int readyToStart;

  TechnicianDashboardModel({
    required this.thisWeekBonus,
    required this.jobsToday,
    required this.thisWeekEarned,
    required this.totalEarned,
    required this.activeJobs,
    required this.completedThisMonth,
    required this.inProgress,
    required this.readyToStart,
  });

  factory TechnicianDashboardModel.fromJson(Map<String, dynamic> json) {
    return TechnicianDashboardModel(
      thisWeekBonus: (json['thisWeekBonus'] as num?)?.toInt() ?? 0,
      jobsToday: (json['jobsToday'] as num?)?.toInt() ?? 0,
      thisWeekEarned: (json['thisWeekEarned'] as num?)?.toInt() ?? 0,
      totalEarned: (json['totalEarned'] as num?)?.toInt() ?? 0,
      activeJobs: (json['activeJobs'] as num?)?.toInt() ?? 0,
      completedThisMonth: (json['completedThisMonth'] as num?)?.toInt() ?? 0,
      inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
      readyToStart: (json['readyToStart'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thisWeekBonus': thisWeekBonus,
      'jobsToday': jobsToday,
      'thisWeekEarned': thisWeekEarned,
      'totalEarned': totalEarned,
      'activeJobs': activeJobs,
      'completedThisMonth': completedThisMonth,
      'inProgress': inProgress,
      'readyToStart': readyToStart,
    };
  }
}

