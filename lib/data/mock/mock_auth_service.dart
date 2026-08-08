import '../mock/mock_data.dart';
import '../models/models.dart';

class MockAuthService {
  bool _isAuthenticated = false;
  final Map<String, String> _registeredPins = {};

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (phone.length >= 10 && otp.length >= 4) {
      _isAuthenticated = true;
      return true;
    }
    return false;
  }

  Future<bool> signUp({
    required String phone,
    required String pin,
    required String otp,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (phone.length < 10 || pin.length < 4 || otp.length < 4) return false;
    _registeredPins[phone] = pin;
    _isAuthenticated = true;
    return true;
  }

  Future<bool> verifyPin(String phone, String pin) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final stored = _registeredPins[phone];
    if (stored == null) return pin.length >= 4;
    return stored == pin;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isAuthenticated = false;
  }

  Agent getCurrentAgent() => MockData.agent;

  Future<Agent> updateAgentProfile(Agent updated) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return updated;
  }
}
