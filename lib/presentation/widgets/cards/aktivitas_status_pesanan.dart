import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapStatusPesananCard extends StatelessWidget {
  final String dateStatusText;
  final String mainTitle;
  final String imagePath;

  const HapHapStatusPesananCard({
    super.key,
    required this.dateStatusText,
    required this.mainTitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: AppSizes.mediaLarge),
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
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateStatusText,
                    style: const AppTextStyle(
                      fontSize: AppTypography.labelMedium,
                      color: AppColors.greyDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    mainTitle,
                    style: const AppTextStyle(
                      fontSize: AppTypography.titleLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: AppRadii.lgRadius,
              bottomRight: AppRadii.lgRadius,
            ),
            child: Image.asset(
              imagePath,
              width: AppSizes.mediaLarge,
              height: AppSizes.mediaLarge,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
