import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_action_buttons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileService _profileService;
  late Future<UserProfile> _userProfileFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService();
    _userProfileFuture = _profileService.fetchUserProfile();
  }

  void _handleEditProfile(UserProfile profile) {
    // TODO: Navigate to edit profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon')),
    );
  }

  void _handleChangePassword() {
    // TODO: Navigate to change password page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password feature coming soon')),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _profileService.logout();
        if (mounted) {
          // TODO: Navigate to login page
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6EE7B7),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userProfileFuture =
                            _profileService.fetchUserProfile();
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Data tidak ditemukan'),
            );
          }

          final profile = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  ProfileHeader(
                    profile: profile,
                    onBackPressed: () => Navigator.pop(context),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      spacing: 16,
                      children: [
                        // Profile Card
                        ProfileCard(profile: profile),
                        // Account Information
                        ProfileInfoSection(
                          title: 'Informasi Akun',
                          items: [
                            ProfileInfoItem(
                              icon: Icons.person,
                              iconColor: const Color(0xFF10B981),
                              iconBackgroundColor:
                                  const Color(0xFF10B981),
                              label: 'Nama Lengkap',
                              value: profile.fullName,
                            ),
                            ProfileInfoItem(
                              icon: Icons.phone,
                              iconColor: const Color(0xFF3B82F6),
                              iconBackgroundColor:
                                  const Color(0xFF3B82F6),
                              label: 'Nomor HP',
                              value: profile.phoneNumber,
                            ),
                            ProfileInfoItem(
                              icon: Icons.email,
                              iconColor: const Color(0xFF8B5CF6),
                              iconBackgroundColor:
                                  const Color(0xFF8B5CF6),
                              label: 'Email',
                              value: profile.email,
                            ),
                            ProfileInfoItem(
                              icon: Icons.person_outline,
                              iconColor: const Color(0xFFF59E0B),
                              iconBackgroundColor:
                                  const Color(0xFFF59E0B),
                              label: 'Username',
                              value: profile.username,
                            ),
                            ProfileInfoItem(
                              icon: Icons.location_on,
                              iconColor: const Color(0xFFEF4444),
                              iconBackgroundColor:
                                  const Color(0xFFEF4444),
                              label: 'Alamat',
                              value: profile.address,
                            ),
                          ],
                        ),
                        // Action Buttons
                        ProfileActionButtons(
                          onEditProfile: () =>
                              _handleEditProfile(profile),
                          onChangePassword: _handleChangePassword,
                          onLogout: _handleLogout,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}