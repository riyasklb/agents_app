import '../mock/mock_data.dart';
import '../models/enums.dart';
import '../models/models.dart';

class MockEarningsService {
  EarningsSummary _summary = MockData.earningsSummary;

  Future<EarningsSummary> getEarningsSummary() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _summary;
  }

  Future<bool> withdrawEarnings(double amount) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true;
  }

  Future<void> onCaseSubmitted(VerificationJob job) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final txn = EarningTransaction(
      id: 'txn-${job.id}',
      amount: job.commission,
      title: '${job.verificationType.shortLabel} · ${job.applicant.name}',
      date: DateTime.now(),
      status: 'Pending review',
      jobId: job.id,
    );
    _summary = EarningsSummary(
      monthlyTotal: _summary.monthlyTotal,
      monthlyGrowth: _summary.monthlyGrowth,
      availableBalance: _summary.availableBalance,
      pendingAmount: _summary.pendingAmount + job.commission,
      totalEarned: _summary.totalEarned,
      dailyEarnings: _summary.dailyEarnings,
      transactions: [txn, ..._summary.transactions],
    );
  }

  Future<void> onCaseApproved(VerificationJob job) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final transactions = _summary.transactions.map((t) {
      if (t.jobId == job.id) {
        return EarningTransaction(
          id: t.id,
          amount: t.amount,
          title: t.title,
          date: t.date,
          status: 'Paid',
          jobId: t.jobId,
        );
      }
      return t;
    }).toList();

    _summary = EarningsSummary(
      monthlyTotal: _summary.monthlyTotal + job.commission,
      monthlyGrowth: _summary.monthlyGrowth,
      availableBalance: _summary.availableBalance + job.commission,
      pendingAmount: (_summary.pendingAmount - job.commission).clamp(0, double.infinity),
      totalEarned: _summary.totalEarned + job.commission,
      dailyEarnings: _summary.dailyEarnings,
      transactions: transactions,
    );
  }

  Future<void> simulateBankApproval(String jobId) async {
    await Future.delayed(const Duration(seconds: 3));
    final txn = _summary.transactions.firstWhere(
      (t) => t.jobId == jobId,
      orElse: () => throw Exception('Transaction not found'),
    );
    if (txn.status == 'Paid') return;

    final jobCommission = txn.amount;
    final transactions = _summary.transactions.map((t) {
      if (t.jobId == jobId) {
        return EarningTransaction(
          id: t.id,
          amount: t.amount,
          title: t.title,
          date: DateTime.now(),
          status: 'Paid',
          jobId: t.jobId,
        );
      }
      return t;
    }).toList();

    _summary = EarningsSummary(
      monthlyTotal: _summary.monthlyTotal + jobCommission,
      monthlyGrowth: _summary.monthlyGrowth,
      availableBalance: _summary.availableBalance + jobCommission,
      pendingAmount: (_summary.pendingAmount - jobCommission).clamp(0, double.infinity),
      totalEarned: _summary.totalEarned + jobCommission,
      dailyEarnings: _summary.dailyEarnings,
      transactions: transactions,
    );
  }
}
