import '../mock/mock_data.dart';
import '../models/models.dart';

class MockVerificationService {
  MockVerificationService();

  static const demoOtp = '123456';

  final Map<String, VerificationSession> _sessions = {};

  Future<VerificationSession> startSession(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final session = VerificationSession(
      jobId: jobId,
      currentStep: 0,
      totalSteps: 5,
      media: MockData.defaultMediaItems(),
      questions: MockData.defaultQuestions(),
      gpsConfirmed: false,
      gpsDistanceMeters: 0,
      otpSent: false,
      otpVerified: false,
      remarks: '',
      isSubmitted: false,
    );
    _sessions[jobId] = session;
    return session;
  }

  Future<VerificationSession?> getSession(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sessions[jobId];
  }

  Future<VerificationSession> updateStep(String jobId, int step) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final session = _sessions[jobId];
    if (session == null) throw Exception('Session not found');
    final updated = session.copyWith(currentStep: step);
    _sessions[jobId] = updated;
    return updated;
  }

  Future<VerificationSession> captureMedia(
    String jobId,
    String mediaId, {
    int? durationSeconds,
    String? filePath,
    GeoStamp? geoStamp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final session = _sessions[jobId];
    if (session == null) throw Exception('Session not found');
    final media = session.media.map((m) {
      if (m.id == mediaId) {
        return m.copyWith(
          isCaptured: true,
          thumbnailPath: filePath ?? 'captured_$mediaId',
          durationSeconds: durationSeconds,
          geoStamp: geoStamp ?? _mockGeoStamp(),
        );
      }
      return m;
    }).toList();
    final updated = session.copyWith(media: media);
    _sessions[jobId] = updated;
    return updated;
  }

  GeoStamp _mockGeoStamp() => GeoStamp(
        latitude: 10.5276,
        longitude: 76.2144,
        capturedAt: DateTime.now(),
        address: 'Thrissur, Kerala',
      );

  Future<VerificationSession> confirmGps(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final session = _sessions[jobId];
    if (session == null) throw Exception('Session not found');
    final updated = session.copyWith(
      gpsConfirmed: true,
      gpsDistanceMeters: 34,
    );
    _sessions[jobId] = updated;
    return updated;
  }

  Future<VerificationSession> sendOtp(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final session = _sessions[jobId];
    if (session == null) throw Exception('Session not found');
    final updated = session.copyWith(otpSent: true);
    _sessions[jobId] = updated;
    return updated;
  }

  Future<bool> verifyOtp(String jobId, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otp != demoOtp) return false;
    final session = _sessions[jobId];
    if (session == null) throw Exception('Session not found');
    final updated = session.copyWith(otpVerified: true);
    _sessions[jobId] = updated;
    return true;
  }

  Future<VerificationSession> answerQuestion(
    String jobId,
    String questionId,
    bool answer,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final session = _sessions[jobId];
    if (session == null) throw Exception('Session not found');
    final questions = session.questions.map((q) {
      if (q.id == questionId) return q.copyWith(answer: answer);
      return q;
    }).toList();
    final updated = session.copyWith(questions: questions);
    _sessions[jobId] = updated;
    return updated;
  }

  Future<VerificationSession> setRemarks(String jobId, String remarks) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final session = _sessions[jobId];
    if (session == null) throw Exception('Session not found');
    final updated = session.copyWith(remarks: remarks);
    _sessions[jobId] = updated;
    return updated;
  }

  Future<VerificationSession> submitVerification(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final session = _sessions[jobId];
    if (session == null) throw Exception('Session not found');
    final updated = session.copyWith(isSubmitted: true);
    _sessions[jobId] = updated;
    return updated;
  }
}
