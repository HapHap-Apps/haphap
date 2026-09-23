import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/network/token_manager.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/data/models/user_profile_model.dart';
import 'package:haphap_fe/data/services/user_service.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/cards/akun_profile_card.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';

class AkunAdminPage extends StatefulWidget {
  const AkunAdminPage({super.key});

  @override
  State<AkunAdminPage> createState() => _AkunAdminPageState();
}

class _AkunAdminPageState extends State<AkunAdminPage> {
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
      if (!mounted) return;
      setState(() {
        _profile = profileData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await TokenManager.deleteToken();
    if (!mounted) return;
    context.go(AppRoutes.login);
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
            name: _profile?.name ?? 'Admin',
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
                        onTap: () => context.push(AppRoutes.editProfil),
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
                        onPressed: _logout,
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
                      color: AppColors.textSecondary,
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
  final VoidCallback onTap;

  _MenuItemData({required this.icon, required this.title, required this.onTap});
}
