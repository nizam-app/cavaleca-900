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
  final double? yourBonus; // Actual bonus amount from API (e.g. 45)
  final double? bonusRate; // Bonus rate percentage from API (e.g. 15)
  final String? description;
  final String? category;
  final JobStatus status;
  final JobPriority? priority;
  final double? latitude;
  final double? longitude;
  final List<Payment>? payments; // Array of payment submissions
  final String? backendStatus; // Original backend status string (e.g. "COMPLETED_PENDING_PAYMENT", "ACCEPTED", "IN_PROGRESS")

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
    this.yourBonus,
    this.bonusRate,
    this.description,
    this.category,
    required this.status,
    this.priority,
    this.latitude,
    this.longitude,
    this.payments,
    this.backendStatus,
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
    double? yourBonus,
    double? bonusRate,
    String? description,
    String? category,
    JobStatus? status,
    JobPriority? priority,
    double? latitude,
    double? longitude,
    List<Payment>? payments,
    String? backendStatus,
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
      yourBonus: yourBonus ?? this.yourBonus,
      bonusRate: bonusRate ?? this.bonusRate,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      payments: payments ?? this.payments,
      backendStatus: backendStatus ?? this.backendStatus,
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

    JobStatus status;
    // Check for new payment-related statuses FIRST (before checking completedAt/startedAt)
    if (backendStatus == 'PAID_VERIFIED') {
      status = JobStatus.paidVerified;
    } else if (backendStatus == 'COMPLETED_PENDING_PAYMENT') {
      status = JobStatus.completedPendingPayment;
    } else if (backendStatus == 'IN_PROGRESS' || json['startedAt'] != null) {
      // Check IN_PROGRESS status or startedAt
      status = JobStatus.inProgress;
    } else if (json['completedAt'] != null && backendStatus != 'COMPLETED_PENDING_PAYMENT') {
      // Only set completed if not COMPLETED_PENDING_PAYMENT
      status = JobStatus.completed;
    } else if (backendStatus == 'ACCEPTED') {
      status = JobStatus.assigned;
    } else {
      status = JobStatus.incoming;
    }

    // Parse payments array
    List<Payment>? paymentsList;
    if (json['payments'] != null && json['payments'] is List) {
      paymentsList = (json['payments'] as List)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // ---- location & payment ----
    final double? lat = (json['latitude'] as num?)?.toDouble();
    final double? lng = (json['longitude'] as num?)?.toDouble();

    final jobPayment = (json['jobPayment'] as num?)?.toDouble() ?? 0;
    final bonusRateFromApi = (json['bonusRate'] as num?)?.toDouble();
    final yourBonusFromApi = (json['yourBonus'] as num?)?.toDouble();
    final paymentStr = '\$${jobPayment.toStringAsFixed(2)}';
    
    // Use yourBonus from API if available, otherwise calculate from bonusRate
    final bonusAmount = yourBonusFromApi ?? (bonusRateFromApi != null ? (jobPayment * bonusRateFromApi / 100) : 0);
    final bonusStr = '\$${bonusAmount.toStringAsFixed(2)}';

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
      yourBonus: yourBonusFromApi,
      bonusRate: bonusRateFromApi,
      description: json['notes'],
      category: category?['name'],
      status: status,
      priority: priority,
      latitude: lat,
      longitude: lng,
      payments: paymentsList,
      backendStatus: json['status'] as String?, // Store original backend status
    );
  }
}

enum JobStatus { 
  incoming, 
  assigned, 
  inProgress, 
  completed,
  completedPendingPayment,
  paidVerified,
}

enum JobPriority { high, medium, low }

/// Payment model for payment submissions
class Payment {
  final int id;
  final String status; // "PENDING_VERIFICATION", "VERIFIED", "REJECTED"
  final String? proofUrl;
  final double amount;
  final String method;
  final String? transactionRef; // Optional - may not be in all API responses

  const Payment({
    required this.id,
    required this.status,
    this.proofUrl,
    required this.amount,
    required this.method,
    this.transactionRef,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Parse status and ensure it's uppercase and trimmed
    final statusStr = (json['status'] as String? ?? '').trim().toUpperCase();
    
    return Payment(
      id: json['id'] as int,
      status: statusStr,
      proofUrl: json['proofUrl'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? '',
      transactionRef: json['transactionRef'] as String?,
    );
  }
}
