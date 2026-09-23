import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

import 'package:haphap_fe/data/services/user_service.dart';
import 'package:haphap_fe/data/services/application_service.dart';
import 'package:haphap_fe/data/models/user_profile_model.dart';

import 'package:haphap_fe/presentation/widgets/cards/akun_profile_card.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';
import 'package:haphap_fe/presentation/pages/customer/akun/edit_profil.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  UserProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profileData = await UserService.getMe();
      setState(() {
        _profile = profileData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatHemat(int totalSaved) {
    if (totalSaved == 0) return 'Belum ada';
    if (totalSaved >= 1000) {
      return 'Hemat ${(totalSaved / 1000).toInt()}rb';
    }
    return 'Hemat $totalSaved';
  }

  Future<void> _handleJoinMerchant(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final freshProfile = await UserService.getMe();
      if (!context.mounted) return;

      setState(() {
        _profile = freshProfile;
      });

      if (freshProfile.role == 'MERCHANT') {
        Navigator.of(context, rootNavigator: true).pop();
        context.go(AppRoutes.merchantBeranda);
        return;
      }

      final myApps = await ApplicationService.findMyApplications();

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      final hasPending = myApps.any((app) => app.status == 'PENDING');
      final hasApproved = myApps.any((app) => app.status == 'APPROVED');

      if (hasApproved) {
        context.go(AppRoutes.merchantBeranda);
      } else if (hasPending) {
        AppSnackbar.showInfo(
          context,
          'Pengajuan pendaftaran merchant Anda sedang diproses oleh Admin.',
        );
      } else {
        context.push(AppRoutes.merchantRegister);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      AppSnackbar.showError(context, 'Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              )
            : _errorMessage != null
            ? Center(
                child: Text(
                  'Error: $_errorMessage',
                  style: const AppTextStyle(color: AppColors.white),
                ),
              )
            : _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: HapHapPageHeader(
            title: 'Profil',
            showBackButton: false,
            titleColor: AppColors.white,
            fontSize: AppTypography.headlineSmall,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: HapHapProfileCard(
            name: _profile?.name ?? 'User',
            email: _profile?.email ?? '-',
            phoneNumber: _profile?.phone ?? '-',
            imageUrl: _profile?.avatar,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: AppRadii.sheetRadius,
                topRight: AppRadii.sheetRadius,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Akun'),
                    _buildMenuCard([
                      _MenuItemData(
                        icon: Icons.edit,
                        title: 'Edit Profil',
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditProfilPage(),
                            ),
                          );
                          if (!mounted) return;
                          setState(() => _isLoading = true);
                          _fetchProfile();
                        },
                      ),
                      _MenuItemData(
                        icon: Icons.info,
                        title: 'Statistik',
                        badge: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: AppRadii.lg,
                          ),
                          child: Text(
                            _formatHemat(_profile?.totalSaved ?? 0),
                            style: const AppTextStyle(
                              fontSize: AppTypography.labelMedium,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        onTap: () {
                          context.push(AppRoutes.statistik);
                        },
                      ),
                    ]),

                    const SizedBox(height: AppSpacing.xxxl),

                    _buildSectionTitle('Selebihnya dari HapHap'),
                    _buildMenuCard([
                      _MenuItemData(
                        icon: Icons.store,
                        title: 'Bergabung sebagai Merchant',
                        onTap: () => _handleJoinMerchant(context),
                      ),
                    ]),

                    const SizedBox(height: AppSpacing.xxxl),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: HapHapButton(
                        text: 'Keluar',
                        isExpanded: true,
                        size: HapHapButtonSize.large,
                        onPressed: () {
                          context.go(AppRoutes.login);
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.bottomClearance),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        bottom: AppSpacing.md,
      ),
      child: Text(
        title,
        style: const AppTextStyle(
          fontSize: AppTypography.bodyLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItemData> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadii.lg,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: items.map((item) {
            return InkWell(
              onTap: item.onTap,
              borderRadius: AppRadii.lg,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: AppSizes.iconSm,
                      color: AppColors.greyDark,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const AppTextStyle(
                          fontSize: AppTypography.bodyLarge,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    if (item.badge != null) ...[
                      item.badge!,
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    const Icon(
                      Icons.chevron_right,
                      size: AppSizes.iconMd,
                      color: AppColors.greyDark,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final Widget? badge;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.badge,
    required this.onTap,
  });
}
