import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/core/constants/app_icons.dart';

class HapHapAktivitasCard extends StatelessWidget {
  final String statusText;
  final String mainText;
  final String restaurantName;
  final String imagePath;

  const HapHapAktivitasCard({
    super.key,
    required this.statusText,
    required this.mainText,
    required this.restaurantName,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusText,
                    style: const AppTextStyle(
                      fontSize: AppTypography.labelMedium,
                      color: AppColors.greyDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    mainText,
                    style: const AppTextStyle(
                      fontSize: AppTypography.titleLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      SizedBox(
                        width: AppSizes.iconXs,
                        height: AppSizes.iconXs,
                        child: SvgPicture.asset(
                          AppIcons.restaurant,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          restaurantName,
                          style: const AppTextStyle(
                            fontSize: AppTypography.labelMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
              width: AppSizes.compactButtonWidth,
              height: AppSizes.mediaLarge,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}
