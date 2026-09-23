import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class AdminApplicationCard extends StatelessWidget {
  final String merchantName;
  final String applicantName;
  final String dateText;
  final String status;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const AdminApplicationCard({
    super.key,
    required this.merchantName,
    required this.applicantName,
    required this.dateText,
    required this.status,
    this.avatarUrl,
    this.onTap,
  });

  Color get _badgeColor {
    switch (status) {
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      case 'PENDING':
      default:
        return AppColors.primary;
    }
  }

  String get _badgeText {
    switch (status) {
      case 'APPROVED':
        return 'DITERIMA';
      case 'REJECTED':
        return 'DITOLAK';
      case 'PENDING':
      default:
        return 'MENUNGGU';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadii.lg,
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _buildAvatar(),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchantName,
                    style: const AppTextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$applicantName · $dateText',
                    style: const AppTextStyle(
                      fontSize: AppTypography.labelMedium,
                      color: AppColors.greyDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _badgeColor.withValues(alpha: 0.12),
                borderRadius: AppRadii.sm,
              ),
              child: Text(
                _badgeText,
                style: AppTextStyle(
                  fontSize: AppTypography.labelMedium,
                  fontWeight: FontWeight.bold,
                  color: _badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      width: AppSizes.navItemWidth,
      height: AppSizes.navItemWidth,
      decoration: BoxDecoration(
        borderRadius: AppRadii.md,
        image: hasAvatar
            ? DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasAvatar
          ? null
          : Center(
              child: Text(
                merchantName.isNotEmpty ? merchantName[0].toUpperCase() : 'M',
                style: const AppTextStyle(
                  fontSize: AppTypography.headlineSmall,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
    );
  }
}
