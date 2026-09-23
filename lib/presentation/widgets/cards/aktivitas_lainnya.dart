import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapAktivitasLainnyaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;

  const HapHapAktivitasLainnyaCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: AppSizes.mediaLarge),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: AppSizes.hairline,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: AppSizes.decorativeImage,
            height: AppSizes.decorativeImage,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: AppSpacing.xxl),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const AppTextStyle(
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    height: AppTypography.lineHeightNormal,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  subtitle,
                  style: const AppTextStyle(
                    fontSize: AppTypography.labelMedium,
                    color: AppColors.greyDark,
                    height: AppTypography.lineHeightRelaxed,
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
