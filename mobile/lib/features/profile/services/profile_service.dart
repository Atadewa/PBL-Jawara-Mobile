import 'package:mobile/features/profile/models/profile_model.dart';

class ProfileService {
  // TODO: Replace with actual API calls
  // For now, using mock data for development

  Future<UserProfile> fetchUserProfile() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    return UserProfile(
      id: '1',
      fullName: 'Budi Santoso',
      username: 'budi.santoso',
      email: 'budi.santoso@email.com',
      phoneNumber: '081234567890',
      address: 'Jl. Mawar No. 15, Kelurahan Suka Maju',
      role: 'Ketua RT',
      rtRw: 'RT 03 / RW 05',
      profilePictureUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    );
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 800));
    // Mock success
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 800));
    // Mock success
  }

  Future<void> logout() async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock success
  }
}