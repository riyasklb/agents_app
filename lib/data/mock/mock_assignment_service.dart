import '../models/enums.dart';
import '../models/models.dart';

typedef JobMutator = void Function(VerificationJob job, int index);

class MockAssignmentService {
  static const progressWindow = Duration(hours: 2);
  static const extensionDuration = Duration(hours: 24);

  /// First-accept wins. Returns null if case was already taken.
  VerificationJob? tryAccept({
    required List<VerificationJob> jobs,
    required int index,
    required String agentId,
  }) {
    final job = jobs[index];
    if (job.status != JobStatus.available) return null;
    if (job.assignedAgentId != null && job.assignedAgentId != agentId) {
      return null;
    }

    final now = DateTime.now();
    final updated = job.copyWith(
      status: JobStatus.accepted,
      assignedAgentId: agentId,
      acceptedAt: now,
      lastProgressAt: now,
      progressDeadline: now.add(progressWindow),
    );
    jobs[index] = updated;
    return updated;
  }

  void recordProgress({
    required List<VerificationJob> jobs,
    required String jobId,
  }) {
    final index = jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    final job = jobs[index];
    if (job.status != JobStatus.accepted &&
        job.status != JobStatus.inProgress) {
      return;
    }
    final now = DateTime.now();
    jobs[index] = job.copyWith(
      status: JobStatus.inProgress,
      lastProgressAt: now,
      progressDeadline: now.add(progressWindow),
    );
  }

  List<String> rollbackExpiredCases(List<VerificationJob> jobs) {
    final rolledBack = <String>[];
    final now = DateTime.now();
    for (var i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      if (job.status != JobStatus.accepted &&
          job.status != JobStatus.inProgress) {
        continue;
      }
      final deadline = job.progressDeadline;
      if (deadline == null || now.isBefore(deadline)) continue;
      jobs[i] = job.copyWith(
        status: JobStatus.available,
        assignedAgentId: null,
        acceptedAt: null,
        lastProgressAt: null,
        progressDeadline: null,
      );
      rolledBack.add(job.id);
    }
    return rolledBack;
  }

  VerificationJob? requestExtension({
    required List<VerificationJob> jobs,
    required String jobId,
    required ExtensionReason reason,
  }) {
    final index = jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return null;
    final job = jobs[index];
    if (job.status != JobStatus.accepted &&
        job.status != JobStatus.inProgress) {
      return null;
    }

    final now = DateTime.now();
    final newDeadline = job.deadline.add(extensionDuration);
    final extension = DeadlineExtension(
      reason: reason,
      extendedAt: now,
      previousDeadline: job.deadline,
      newDeadline: newDeadline,
    );
    final updated = job.copyWith(
      deadline: newDeadline,
      lastProgressAt: now,
      progressDeadline: now.add(progressWindow),
      deadlineExtensions: [...job.deadlineExtensions, extension],
      remarks: reason.label,
    );
    jobs[index] = updated;
    return updated;
  }
}
