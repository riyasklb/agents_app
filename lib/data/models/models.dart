import 'enums.dart';

class GeoStamp {
  const GeoStamp({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final String address;
}

class AgentAllocationPreferences {
  const AgentAllocationPreferences({
    required this.mode,
    required this.pincodes,
    required this.distanceRadiusKm,
  });

  final AllocationMode mode;
  final List<String> pincodes;
  final double distanceRadiusKm;

  AgentAllocationPreferences copyWith({
    AllocationMode? mode,
    List<String>? pincodes,
    double? distanceRadiusKm,
  }) {
    return AgentAllocationPreferences(
      mode: mode ?? this.mode,
      pincodes: pincodes ?? this.pincodes,
      distanceRadiusKm: distanceRadiusKm ?? this.distanceRadiusKm,
    );
  }
}

class DeadlineExtension {
  const DeadlineExtension({
    required this.reason,
    required this.extendedAt,
    required this.previousDeadline,
    required this.newDeadline,
  });

  final ExtensionReason reason;
  final DateTime extendedAt;
  final DateTime previousDeadline;
  final DateTime newDeadline;
}

class Agent {
  const Agent({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.avatarInitials,
    required this.avatarUrl,
    required this.rating,
    required this.totalJobs,
    required this.successRate,
    required this.totalEarned,
    required this.location,
    required this.isVerified,
    required this.kycStatus,
    required this.serviceAreas,
    required this.address,
    required this.aadhaarMasked,
    required this.aadhaarVerified,
    required this.certification,
    required this.certificationVerified,
    required this.upiId,
    required this.allocationPreferences,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatarInitials;
  final String avatarUrl;
  final double rating;
  final int totalJobs;
  final double successRate;
  final double totalEarned;
  final String location;
  final bool isVerified;
  final AgentKycStatus kycStatus;
  final List<String> serviceAreas;
  final String address;
  final String aadhaarMasked;
  final bool aadhaarVerified;
  final String certification;
  final bool certificationVerified;
  final String upiId;
  final AgentAllocationPreferences allocationPreferences;

  Agent copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? upiId,
    String? certification,
    AgentAllocationPreferences? allocationPreferences,
  }) {
    return Agent(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarInitials: avatarInitials,
      avatarUrl: avatarUrl,
      rating: rating,
      totalJobs: totalJobs,
      successRate: successRate,
      totalEarned: totalEarned,
      location: location,
      isVerified: isVerified,
      kycStatus: kycStatus,
      serviceAreas: serviceAreas,
      address: address ?? this.address,
      aadhaarMasked: aadhaarMasked,
      aadhaarVerified: aadhaarVerified,
      certification: certification ?? this.certification,
      certificationVerified: certificationVerified,
      upiId: upiId ?? this.upiId,
      allocationPreferences:
          allocationPreferences ?? this.allocationPreferences,
    );
  }
}

class AgentKycStatus {
  const AgentKycStatus({
    required this.identityVerified,
    required this.bankAccountVerified,
    required this.backgroundCheckCompleted,
    required this.status,
  });

  final bool identityVerified;
  final bool bankAccountVerified;
  final bool backgroundCheckCompleted;
  final String status;
}

class Applicant {
  const Applicant({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.initials,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
  final String initials;
  final String avatarUrl;
}

class VerificationJob {
  const VerificationJob({
    required this.id,
    required this.applicationId,
    required this.loanType,
    required this.verificationType,
    required this.applicant,
    required this.location,
    required this.pincode,
    required this.distanceKm,
    required this.commission,
    required this.deadline,
    required this.status,
    required this.priority,
    required this.estimatedMinutes,
    required this.requirements,
    this.completedAt,
    this.remarks,
    this.assignedAgentId,
    this.acceptedAt,
    this.lastProgressAt,
    this.progressDeadline,
    this.paymentStatus = PaymentStatus.none,
    this.deadlineExtensions = const [],
  });

  final String id;
  final String applicationId;
  final LoanType loanType;
  final VerificationType verificationType;
  final Applicant applicant;
  final String location;
  final String pincode;
  final double distanceKm;
  final double commission;
  final DateTime deadline;
  final JobStatus status;
  final JobPriority priority;
  final int estimatedMinutes;
  final List<String> requirements;
  final DateTime? completedAt;
  final String? remarks;
  final String? assignedAgentId;
  final DateTime? acceptedAt;
  final DateTime? lastProgressAt;
  final DateTime? progressDeadline;
  final PaymentStatus paymentStatus;
  final List<DeadlineExtension> deadlineExtensions;

  VerificationJob copyWith({
    String? id,
    String? applicationId,
    LoanType? loanType,
    VerificationType? verificationType,
    Applicant? applicant,
    String? location,
    String? pincode,
    double? distanceKm,
    double? commission,
    DateTime? deadline,
    JobStatus? status,
    JobPriority? priority,
    int? estimatedMinutes,
    List<String>? requirements,
    DateTime? completedAt,
    String? remarks,
    String? assignedAgentId,
    DateTime? acceptedAt,
    DateTime? lastProgressAt,
    DateTime? progressDeadline,
    PaymentStatus? paymentStatus,
    List<DeadlineExtension>? deadlineExtensions,
  }) {
    return VerificationJob(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      loanType: loanType ?? this.loanType,
      verificationType: verificationType ?? this.verificationType,
      applicant: applicant ?? this.applicant,
      location: location ?? this.location,
      pincode: pincode ?? this.pincode,
      distanceKm: distanceKm ?? this.distanceKm,
      commission: commission ?? this.commission,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      requirements: requirements ?? this.requirements,
      completedAt: completedAt ?? this.completedAt,
      remarks: remarks ?? this.remarks,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      lastProgressAt: lastProgressAt ?? this.lastProgressAt,
      progressDeadline: progressDeadline ?? this.progressDeadline,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deadlineExtensions: deadlineExtensions ?? this.deadlineExtensions,
    );
  }
}

class VerificationMedia {
  const VerificationMedia({
    required this.id,
    required this.type,
    required this.label,
    required this.isCaptured,
    this.thumbnailPath,
    this.durationSeconds,
    this.geoStamp,
  });

  final String id;
  final MediaType type;
  final String label;
  final bool isCaptured;
  final String? thumbnailPath;
  final int? durationSeconds;
  final GeoStamp? geoStamp;

  VerificationMedia copyWith({
    String? id,
    MediaType? type,
    String? label,
    bool? isCaptured,
    String? thumbnailPath,
    int? durationSeconds,
    GeoStamp? geoStamp,
  }) {
    return VerificationMedia(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      isCaptured: isCaptured ?? this.isCaptured,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      geoStamp: geoStamp ?? this.geoStamp,
    );
  }
}

class VerificationQuestion {
  const VerificationQuestion({
    required this.id,
    required this.category,
    required this.question,
    this.answer,
  });

  final String id;
  final String category;
  final String question;
  final bool? answer;

  VerificationQuestion copyWith({
    String? id,
    String? category,
    String? question,
    bool? answer,
  }) {
    return VerificationQuestion(
      id: id ?? this.id,
      category: category ?? this.category,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }
}

class VerificationSession {
  const VerificationSession({
    required this.jobId,
    required this.currentStep,
    required this.totalSteps,
    required this.media,
    required this.questions,
    required this.gpsConfirmed,
    required this.gpsDistanceMeters,
    required this.otpSent,
    required this.otpVerified,
    required this.remarks,
    required this.isSubmitted,
  });

  final String jobId;
  final int currentStep;
  final int totalSteps;
  final List<VerificationMedia> media;
  final List<VerificationQuestion> questions;
  final bool gpsConfirmed;
  final double gpsDistanceMeters;
  final bool otpSent;
  final bool otpVerified;
  final String remarks;
  final bool isSubmitted;

  VerificationSession copyWith({
    String? jobId,
    int? currentStep,
    int? totalSteps,
    List<VerificationMedia>? media,
    List<VerificationQuestion>? questions,
    bool? gpsConfirmed,
    double? gpsDistanceMeters,
    bool? otpSent,
    bool? otpVerified,
    String? remarks,
    bool? isSubmitted,
  }) {
    return VerificationSession(
      jobId: jobId ?? this.jobId,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      media: media ?? this.media,
      questions: questions ?? this.questions,
      gpsConfirmed: gpsConfirmed ?? this.gpsConfirmed,
      gpsDistanceMeters: gpsDistanceMeters ?? this.gpsDistanceMeters,
      otpSent: otpSent ?? this.otpSent,
      otpVerified: otpVerified ?? this.otpVerified,
      remarks: remarks ?? this.remarks,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class EarningTransaction {
  const EarningTransaction({
    required this.id,
    required this.amount,
    required this.title,
    required this.date,
    required this.status,
    required this.jobId,
  });

  final String id;
  final double amount;
  final String title;
  final DateTime date;
  final String status;
  final String jobId;
}

class EarningsSummary {
  const EarningsSummary({
    required this.monthlyTotal,
    required this.monthlyGrowth,
    required this.availableBalance,
    required this.pendingAmount,
    required this.totalEarned,
    required this.dailyEarnings,
    required this.transactions,
  });

  final double monthlyTotal;
  final double monthlyGrowth;
  final double availableBalance;
  final double pendingAmount;
  final double totalEarned;
  final List<DailyEarning> dailyEarnings;
  final List<EarningTransaction> transactions;
}

class DailyEarning {
  const DailyEarning({
    required this.day,
    required this.amount,
  });

  final String day;
  final double amount;
}

class DashboardStats {
  const DashboardStats({
    required this.available,
    required this.accepted,
    required this.completed,
    required this.pending,
    required this.monthlyEarnings,
    required this.monthlyGrowth,
    required this.weeklyEarnings,
  });

  final int available;
  final int accepted;
  final int completed;
  final int pending;
  final double monthlyEarnings;
  final double monthlyGrowth;
  final List<double> weeklyEarnings;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
