import '../mock/mock_data.dart';
import '../models/enums.dart';
import '../models/models.dart';

class MockPreferencesService {
  AgentAllocationPreferences _preferences = MockData.defaultAllocationPreferences;

  AgentAllocationPreferences get preferences => _preferences;

  Future<AgentAllocationPreferences> getAllocationPreferences() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _preferences;
  }

  Future<AgentAllocationPreferences> saveAllocationPreferences(
    AgentAllocationPreferences prefs,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _preferences = prefs;
    return _preferences;
  }

  bool matchesJob(VerificationJob job) {
    if (_preferences.mode == AllocationMode.pincode) {
      if (_preferences.pincodes.isEmpty) return true;
      return _preferences.pincodes.contains(job.pincode);
    }
    return job.distanceKm <= _preferences.distanceRadiusKm;
  }

  List<VerificationJob> filterJobs(List<VerificationJob> jobs) {
    return jobs.where(matchesJob).toList();
  }

  String get summaryLabel {
    if (_preferences.mode == AllocationMode.pincode) {
      if (_preferences.pincodes.isEmpty) return 'All pincodes';
      if (_preferences.pincodes.length == 1) {
        return 'PIN ${_preferences.pincodes.first}';
      }
      return '${_preferences.pincodes.length} pincodes';
    }
    return 'Within ${_preferences.distanceRadiusKm.toStringAsFixed(0)} km';
  }
}
