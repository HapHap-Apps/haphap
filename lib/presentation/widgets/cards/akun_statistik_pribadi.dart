import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapStatistikPribadiCard extends StatelessWidget {
  final String title;
  final String valuePrefix;
  final String value;
  final Color valueColor;
  final String dateText;
  final String imagePath;

  const HapHapStatistikPribadiCard({
    super.key,
    required this.title,
    this.valuePrefix = '',
    required this.value,
    required this.valueColor,
    required this.dateText,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: AppSizes.mediaLarge),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lg,
        boxShadow: AppShadows.card,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -4,
            bottom: 0,
            child: Image.asset(
              imagePath,
              height: AppSizes.decorativeMedia,
              fit: BoxFit.contain,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xxl,
              top: AppSpacing.xxl,
              bottom: AppSpacing.xxl,
              right: AppSpacing.largeSection,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const AppTextStyle(
                    fontSize: AppTypography.labelMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greyDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                RichText(
                  text: TextSpan(
                    children: [
                      if (valuePrefix.isNotEmpty)
                        TextSpan(
                          text: valuePrefix,
                          style: AppTextStyle(
                            fontSize: AppTypography.bodyLarge,
                            fontWeight: FontWeight.bold,
                            color: valueColor,
                          ),
                        ),
                      TextSpan(
                        text: value,
                        style: AppTextStyle(
                          fontSize: AppTypography.headlineSmall,
                          fontWeight: FontWeight.bold,
                          color: valueColor,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  dateText,
                  style: const AppTextStyle(
                    fontSize: AppTypography.labelMedium,
                    color: AppColors.grey,
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
