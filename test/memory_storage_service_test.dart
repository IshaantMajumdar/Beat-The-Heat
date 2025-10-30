import 'package:flutter_test/flutter_test.dart';
import '../lib/services/memory_storage_service.dart';
import '../lib/models/user_profile.dart';

void main() {
  late MemoryStorageService memoryStorage;

  setUp(() {
    memoryStorage = MemoryStorageService();
  });

  test('MemoryStorageService initializes with empty data', () {
    expect(memoryStorage.hasUserConsent, isFalse);
    expect(memoryStorage.sessionData.userProfile, isNull);
  });

  test('MemoryStorageService updates user consent', () {
    memoryStorage.updateUserConsent(true);
    expect(memoryStorage.hasUserConsent, isTrue);

    memoryStorage.updateUserConsent(false);
    expect(memoryStorage.hasUserConsent, isFalse);
  });

  test('MemoryStorageService stores and retrieves user profile', () {
    final testProfile = UserProfile(
      age: 30,
      gender: Gender.other,
      hasCardio: false,
      hasRespiratory: true,
      hasDiabetes: false,
      hasHypertension: false,
      activityLevel: ActivityLevel.moderate,
      consented: true,
    );

    memoryStorage.sessionData.setUserProfile(testProfile);
    expect(memoryStorage.sessionData.userProfile, equals(testProfile));
  });

  test('MemoryStorageService clears session data', () {
    // Set up some data
    memoryStorage.updateUserConsent(true);
    memoryStorage.sessionData.setUserProfile(
      UserProfile(
        age: 30,
        gender: Gender.other,
        hasCardio: false,
        hasRespiratory: false,
        hasDiabetes: false,
        hasHypertension: false,
        activityLevel: ActivityLevel.moderate,
        consented: true,
      ),
    );

    // Clear the session
    memoryStorage.clearSession();

    // Verify everything is cleared
    expect(memoryStorage.hasUserConsent, isFalse);
    expect(memoryStorage.sessionData.userProfile, isNull);
  });
}