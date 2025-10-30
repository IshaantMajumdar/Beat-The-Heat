import '../models/session_data.dart';

/// A service that manages in-memory data storage during app runtime
class MemoryStorageService {
  static final MemoryStorageService _instance = MemoryStorageService._internal();
  factory MemoryStorageService() => _instance;
  MemoryStorageService._internal();

  final SessionData _sessionData = SessionData();

  // Getter for session data
  SessionData get sessionData => _sessionData;

  // Initialize session
  void initializeSession() {
    _sessionData.clearSession();
  }

  // Check if user has provided consent
  bool get hasUserConsent => _sessionData.hasUserConsent;

  // Update user consent
  void updateUserConsent(bool consent) {
    _sessionData.setUserConsent(consent);
  }

  // Cleanup session data
  void clearSession() {
    _sessionData.clearSession();
  }
}