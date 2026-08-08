import 'enums.dart';

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
    required this.distanceKm,
    required this.commission,
    required this.deadline,
    required this.status,
    required this.priority,
    required this.estimatedMinutes,
    required this.requirements,
    this.completedAt,
    this.remarks,
  });

  final String id;
  final String applicationId;
  final LoanType loanType;
  final VerificationType verificationType;
  final Applicant applicant;
  final String location;
  final double distanceKm;
  final double commission;
  final DateTime deadline;
  final JobStatus status;
  final JobPriority priority;
  final int estimatedMinutes;
  final List<String> requirements;
  final DateTime? completedAt;
  final String? remarks;

  VerificationJob copyWith({
    String? id,
    String? applicationId,
    LoanType? loanType,
    VerificationType? verificationType,
    Applicant? applicant,
    String? location,
    double? distanceKm,
    double? commission,
    DateTime? deadline,
    JobStatus? status,
    JobPriority? priority,
    int? estimatedMinutes,
    List<String>? requirements,
    DateTime? completedAt,
    String? remarks,
  }) {
    return VerificationJob(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      loanType: loanType ?? this.loanType,
      verificationType: verificationType ?? this.verificationType,
      applicant: applicant ?? this.applicant,
      location: location ?? this.location,
      distanceKm: distanceKm ?? this.distanceKm,
      commission: commission ?? this.commission,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      requirements: requirements ?? this.requirements,
      completedAt: completedAt ?? this.completedAt,
      remarks: remarks ?? this.remarks,
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
  });

  final String id;
  final MediaType type;
  final String label;
  final bool isCaptured;
  final String? thumbnailPath;
  final int? durationSeconds;

  VerificationMedia copyWith({
    String? id,
    MediaType? type,
    String? label,
    bool? isCaptured,
    String? thumbnailPath,
    int? durationSeconds,
  }) {
    return VerificationMedia(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      isCaptured: isCaptured ?? this.isCaptured,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
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
