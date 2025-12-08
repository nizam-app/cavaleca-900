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
      thisWeekBonus: json['thisWeekBonus'] ?? 0,
      jobsToday: json['jobsToday'] ?? 0,
      thisWeekEarned: json['thisWeekEarned'] ?? 0,
      totalEarned: json['totalEarned'] ?? 0,
      activeJobs: json['activeJobs'] ?? 0,
      completedThisMonth: json['completedThisMonth'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      readyToStart: json['readyToStart'] ?? 0,
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

