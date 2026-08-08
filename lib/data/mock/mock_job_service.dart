import '../mock/mock_data.dart';
import '../models/enums.dart';
import '../models/models.dart';

class MockJobService {
  final List<VerificationJob> _jobs =
      List<VerificationJob>.from(MockData.jobs);

  Future<List<VerificationJob>> getJobs({bool simulateDelay = true}) async {
    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 800));
    }
    return List<VerificationJob>.from(_jobs);
  }

  Future<VerificationJob?> getJobById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<VerificationJob>> getAvailableJobs() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _jobs.where((j) => j.status == JobStatus.available).toList();
  }

  Future<List<VerificationJob>> getJobsByStatus(JobStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _jobs.where((j) => j.status == status).toList();
  }

  Future<List<VerificationJob>> getActiveJobs() async {
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

  Future<VerificationJob> acceptJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');
    _jobs[index] = _jobs[index].copyWith(status: JobStatus.accepted);
    return _jobs[index];
  }

  Future<VerificationJob> rejectJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');
    _jobs[index] = _jobs[index].copyWith(status: JobStatus.rejected);
    return _jobs[index];
  }

  Future<VerificationJob> submitJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');
    _jobs[index] = _jobs[index].copyWith(
      status: JobStatus.submitted,
      completedAt: DateTime.now(),
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
          j.loanType.label.toLowerCase().contains(lower) ||
          j.location.toLowerCase().contains(lower);
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
    if (filter == 'Highest Pay') {
      return List.from(jobs)
        ..sort((a, b) => b.commission.compareTo(a.commission));
    }
    if (filter == 'Due Today') {
      final today = DateTime.now();
      return jobs.where((j) {
        return j.deadline.year == today.year &&
            j.deadline.month == today.month &&
            j.deadline.day == today.day;
      }).toList();
    }
    if (filter == 'Home Loan') {
      return jobs.where((j) => j.loanType == LoanType.homeLoan).toList();
    }
    if (filter == 'Personal Loan') {
      return jobs.where((j) => j.loanType == LoanType.personalLoan).toList();
    }
    if (filter == 'Business') {
      return jobs.where((j) => j.loanType == LoanType.businessLoan).toList();
    }
    return jobs;
  }
}
