import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapStatsCard extends StatelessWidget {
  final String title;
  final String prefixText;
  final String mainValue;
  final Color valueColor;
  final String subtitle;

  const HapHapStatsCard({
    super.key,
    required this.title,
    this.prefixText = '',
    required this.mainValue,
    required this.valueColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: AppSizes.statsCard),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: AppSizes.hairline,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const AppTextStyle(
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    if (prefixText.isNotEmpty)
                      TextSpan(
                        text: prefixText,
                        style: const AppTextStyle(
                          fontSize: AppTypography.titleLarge,
                        ),
                      ),
                    TextSpan(
                      text: mainValue,
                      style: const AppTextStyle(
                        fontSize: AppTypography.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const AppTextStyle(
                  fontSize: AppTypography.labelMedium,
                  color: AppColors.greyLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
