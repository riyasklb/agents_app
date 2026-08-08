import '../mock/mock_data.dart';
import '../models/models.dart';

class MockAuthService {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (phone.length >= 10 && otp.length >= 4) {
      _isAuthenticated = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isAuthenticated = false;
  }

  Agent getCurrentAgent() => MockData.agent;
}
