import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/providers/user_context_provider.dart';
import '../../../../core/auth/auth_session.dart';

/// Waiting approval page
/// Shown when user account is not yet activated by admin
class WaitingApprovalPage extends StatefulWidget {
  const WaitingApprovalPage({super.key});

  @override
  State<WaitingApprovalPage> createState() => _WaitingApprovalPageState();
}

class _WaitingApprovalPageState extends State<WaitingApprovalPage> {
  final _userContextProvider = UserContextProvider();
  bool _isChecking = false;

  /// Try to load context again (in case admin has approved)
  Future<void> _handleRetry() async {
    setState(() => _isChecking = true);

    final success = await _userContextProvider.loadContextAfterLogin();

    if (!mounted) return;

    setState(() => _isChecking = false);

    if (success && _userContextProvider.context != null) {
      // Account has been approved!
      _showSuccessMessage('Akun Anda telah disetujui!');
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (_userContextProvider.error == 'WAITING_APPROVAL') {
      _showInfoMessage('Akun masih menunggu persetujuan admin');
    } else {
      _showErrorMessage(
        'Gagal memeriksa status: ${_userContextProvider.error}',
      );
    }
  }

  /// Logout and return to login page
  Future<void> _handleLogout() async {
    setState(() => _isChecking = true);

    try {
      await Supabase.instance.client.auth.signOut();
      _userContextProvider.clear();
      AuthSession.logout();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('Gagal logout: $e');
      setState(() => _isChecking = false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Waiting icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule,
                    size: 60,
                    color: Colors.orange.shade700,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Menunggu Persetujuan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'Akun Anda sedang menunggu persetujuan dari admin RT/RW. '
                  'Anda akan dapat mengakses aplikasi setelah akun disetujui.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 48),

                // Retry button
                // SizedBox(
                //   width: double.infinity,
                //   child: CustomButton(
                //     text: 'Coba Lagi',
                //     onPressed: _isChecking ? null : _handleRetry,
                //     isLoading: _isChecking,
                //   ),
                // ),

                const SizedBox(height: 16),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isChecking ? null : _handleLogout,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Additional info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hubungi admin RT/RW Anda jika proses persetujuan memakan waktu lama.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
