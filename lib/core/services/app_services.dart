import '../../data/mock/mock_auth_service.dart';
import '../../data/mock/mock_earnings_service.dart';
import '../../data/mock/mock_job_service.dart';
import '../../data/mock/mock_notification_service.dart';
import '../../data/mock/mock_verification_service.dart';

class AppServices {
  AppServices._();

  static final auth = MockAuthService();
  static final jobs = MockJobService();
  static final verification = MockVerificationService();
  static final earnings = MockEarningsService();
  static final notifications = MockNotificationService();
}
