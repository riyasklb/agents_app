import '../mock/mock_assignment_service.dart';
import '../mock/mock_data.dart';
import '../models/enums.dart';
import '../models/models.dart';

class MockJobService {
  final List<VerificationJob> _jobs =
      List<VerificationJob>.from(MockData.jobs);
  final _assignment = MockAssignmentService();

  List<VerificationJob> get jobs => _jobs;

  Future<void> checkRollbacks() async {
    final rolled = _assignment.rollbackExpiredCases(_jobs);
    if (rolled.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<List<VerificationJob>> getJobs({bool simulateDelay = true}) async {
    await checkRollbacks();
    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 800));
    }
    return List<VerificationJob>.from(_jobs);
  }

  Future<VerificationJob?> getJobById(String id) async {
    await checkRollbacks();
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<VerificationJob>> getAvailableJobs() async {
    await checkRollbacks();
    await Future.delayed(const Duration(milliseconds: 600));
    return _jobs.where((j) => j.status == JobStatus.available).toList();
  }

  Future<List<VerificationJob>> getJobsByStatus(JobStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _jobs.where((j) => j.status == status).toList();
  }

  Future<List<VerificationJob>> getActiveJobs() async {
    await checkRollbacks();
    await Future.delayed(const Duration(milliseconds: 500));
    return _jobs
        .where((j) =>
            j.status == JobStatus.accepted ||
            j.status == JobStatus.inProgress)
        .toList();
  }

  Future<List<VerificationJob>> getSubmittedJobs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _jobs.where((j) => j.status == JobStatus.submitted).toList();
  }

  Future<List<VerificationJob>> getCompletedJobs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _jobs
        .where((j) =>
            j.status == JobStatus.completed ||
            j.status == JobStatus.approved)
        .toList();
  }

  Future<List<VerificationJob>> getAcceptedCasesForAgent(String agentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _jobs
        .where((j) =>
            j.assignedAgentId == agentId &&
            (j.status == JobStatus.accepted ||
                j.status == JobStatus.inProgress ||
                j.status == JobStatus.submitted))
        .toList();
  }

  /// First-accept wins. Throws if case already taken.
  Future<VerificationJob> acceptJob(String jobId, {String? agentId}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');

    final accepted = _assignment.tryAccept(
      jobs: _jobs,
      index: index,
      agentId: agentId ?? MockData.agent.id,
    );
    if (accepted == null) {
      throw Exception('Case already accepted by another agent');
    }
    return accepted;
  }

  Future<VerificationJob> rejectJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');
    _jobs[index] = _jobs[index].copyWith(status: JobStatus.rejected);
    return _jobs[index];
  }

  Future<VerificationJob> recordProgress(String jobId) async {
    _assignment.recordProgress(jobs: _jobs, jobId: jobId);
    return _jobs.firstWhere((j) => j.id == jobId);
  }

  Future<VerificationJob> requestExtension(
    String jobId,
    ExtensionReason reason,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final updated = _assignment.requestExtension(
      jobs: _jobs,
      jobId: jobId,
      reason: reason,
    );
    if (updated == null) throw Exception('Unable to extend deadline');
    return updated;
  }

  Future<VerificationJob> submitJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');
    _jobs[index] = _jobs[index].copyWith(
      status: JobStatus.submitted,
      completedAt: DateTime.now(),
      paymentStatus: PaymentStatus.pendingReview,
      progressDeadline: null,
    );
    return _jobs[index];
  }

  Future<VerificationJob> approveJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');
    _jobs[index] = _jobs[index].copyWith(
      status: JobStatus.approved,
      paymentStatus: PaymentStatus.paid,
    );
    return _jobs[index];
  }

  Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return MockData.dashboardStats;
  }

  List<VerificationJob> searchJobs(String query) {
    if (query.isEmpty) return List.from(_jobs);
    final lower = query.toLowerCase();
    return _jobs.where((j) {
      return j.applicant.name.toLowerCase().contains(lower) ||
          j.verificationType.label.toLowerCase().contains(lower) ||
          j.applicationId.toLowerCase().contains(lower) ||
          j.location.toLowerCase().contains(lower) ||
          j.pincode.contains(lower);
    }).toList();
  }

  List<VerificationJob> filterJobs({
    required List<VerificationJob> jobs,
    String? filter,
  }) {
    if (filter == null || filter == 'Nearby') {
      return List.from(jobs)
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    if (filter == 'Due Today') {
      final today = DateTime.now();
      return jobs.where((j) {
        return j.deadline.year == today.year &&
            j.deadline.month == today.month &&
            j.deadline.day == today.day;
      }).toList();
    }
    if (filter == 'Address') {
      return jobs
          .where((j) => j.verificationType == VerificationType.residentialAddress)
          .toList();
    }
    if (filter == 'Business') {
      return jobs
          .where((j) => j.verificationType == VerificationType.businessAddress)
          .toList();
    }
    if (filter == 'Property') {
      return jobs
          .where(
            (j) => j.verificationType == VerificationType.propertyVerification,
          )
          .toList();
    }
    if (filter == 'Identity') {
      return jobs
          .where(
            (j) => j.verificationType == VerificationType.identityVerification,
          )
          .toList();
    }
    return jobs;
  }
}
