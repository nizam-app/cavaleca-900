class InternalJob {
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

  const InternalJob({
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

  InternalJob copyWith({
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
    return InternalJob(
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

  factory InternalJob.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final category = json['category'] as Map<String, dynamic>?;
    final subservice = json['subservice'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;

    // ---- schedule -> date/time string ----
    final scheduledAtStr = json['scheduledAt'] as String?;
    DateTime? scheduledAt = scheduledAtStr != null
        ? DateTime.parse(scheduledAtStr)
        : null;

    String dateStr = '';
    String? timeStr;

    if (scheduledAt != null) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      dateStr =
          '${months[scheduledAt.month - 1]} ${scheduledAt.day}, ${scheduledAt.year}';

      final hour12 = scheduledAt.hour % 12 == 0 ? 12 : scheduledAt.hour % 12;
      final minute = scheduledAt.minute.toString().padLeft(2, '0');
      final ampm = scheduledAt.hour >= 12 ? 'PM' : 'AM';
      timeStr = '$hour12:$minute $ampm';
    }

    // ---- priority mapping ----
    final backendPriority = (json['priority'] as String? ?? '').toUpperCase();
    JobPriority? priority;
    switch (backendPriority) {
      case 'HIGH':
        priority = JobPriority.high;
        break;
      case 'MEDIUM':
        priority = JobPriority.medium;
        break;
      case 'LOW':
        priority = JobPriority.low;
        break;
    }

    // ---- status mapping: incoming / active / done ----
    final backendStatus = (json['status'] as String? ?? '').toUpperCase();
    final startedAt = json['startedAt'];
    final completedAt = json['completedAt'];

    JobStatus status;
    if (json['completedAt'] != null) {
      status = JobStatus.completed;
    } else if (json['startedAt'] != null) {
      status = JobStatus.inProgress;
    } else if ((json['status'] as String?)?.toUpperCase() == 'ACCEPTED') {
      status = JobStatus.assigned;
    } else {
      status = JobStatus.incoming;
    }

    // ---- location & payment ----
    final double? lat = (json['latitude'] as num?)?.toDouble();
    final double? lng = (json['longitude'] as num?)?.toDouble();

    final jobPayment = (json['jobPayment'] as num?)?.toDouble() ?? 0;
    final bonusRateFromApi = (json['bonusRate'] as num?)?.toDouble() ?? 5;
    final paymentStr = '\$${jobPayment.toStringAsFixed(2)}';
    final bonusStr =
        '\$${(jobPayment * bonusRateFromApi / 100).toStringAsFixed(2)}';

    // ---- title preference: subservice > service > category > WO number ----
    final title =
        subservice?['name'] ??
        service?['name'] ??
        category?['name'] ??
        (json['woNumber'] != null
            ? 'Work Order ${json['woNumber']}'
            : 'Work Order');

    return InternalJob(
      id: json['id'] as int,
      title: title,
      customer: customer?['name'] ?? 'Customer',
      customerPhone: customer?['phone'],
      location: json['address'] ?? '',
      address: json['address'],
      date: dateStr,
      time: timeStr,
      payment: paymentStr,
      bonus: bonusStr,
      description: json['notes'],
      category: category?['name'],
      status: status,
      priority: priority,
      latitude: lat,
      longitude: lng,
    );
  }
}

enum JobStatus { incoming, assigned, inProgress, completed }

enum JobPriority { high, medium, low }
