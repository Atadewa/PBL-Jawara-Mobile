import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import '../../data/models/seller_profile.dart';
import '../../data/services/seller_profile_service.dart';

class SellerProfilePage extends StatefulWidget {
  final String sellerName;
  final String sellerId;

  const SellerProfilePage({
    super.key,
    required this.sellerName,
    required this.sellerId,
  });

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final SellerProfileService _service = SellerProfileService();
  late Future<SellerProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _service.getSellerProfile(
      widget.sellerId,
      fallbackName: widget.sellerName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.50, 0.00),
                end: Alignment(0.50, 1.00),
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.background,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Profil Penjual',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<SellerProfile>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.success),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(
                    child: Text('Gagal memuat profil'),
                  );
                }

                final profile = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowMedium,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: AppColors.shadowMedium,
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                              spreadRadius: -1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: AppColors.successSurface,
                              child: profile.avatarUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        profile.avatarUrl!,
                                        width: 92,
                                        height: 92,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return _defaultAvatarIcon();
                                        },
                                      ),
                                    )
                                  : _defaultAvatarIcon(),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        title: 'Alamat Rumah',
                        icon: Icons.home_outlined,
                        value: profile.address,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        title: 'Keluarga',
                        icon: Icons.groups_outlined,
                        value: profile.family,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatarIcon() {
    return const Icon(
      Icons.person,
      color: AppColors.successDark,
      size: 32,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.successSurfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.successDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

