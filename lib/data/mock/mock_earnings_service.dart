import '../mock/mock_data.dart';
import '../models/models.dart';

class MockEarningsService {
  Future<EarningsSummary> getEarningsSummary() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockData.earningsSummary;
  }

  Future<bool> withdrawEarnings(double amount) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true;
  }
}
