import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapMerchantMenuCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String stockText;
  final String imageUrl;
  final bool isSoldOut;
  final VoidCallback? onDeactivate;

  const HapHapMerchantMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.stockText,
    required this.imageUrl,
    this.isSoldOut = false,
    this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          ColorFiltered(
            colorFilter: isSoldOut
                ? const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ])
                : const ColorFilter.mode(
                    AppColors.transparent,
                    BlendMode.multiply,
                  ),
            child: ClipRRect(
              borderRadius: AppRadii.md,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: AppSizes.thumbnailCompact,
                      height: AppSizes.thumbnailCompact,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: AppSizes.thumbnailCompact,
                          height: AppSizes.thumbnailCompact,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: AppRadii.md,
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.greyDark,
                            size: AppSizes.iconLargePlus,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: AppSizes.thumbnailCompact,
                      height: AppSizes.thumbnailCompact,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: AppRadii.md,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: AppColors.greyDark,
                        size: AppSizes.iconLargePlus,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const AppTextStyle(
                          fontSize: AppTypography.bodyMedium,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onDeactivate != null)
                      GestureDetector(
                        onTap: onDeactivate,
                        child: const Padding(
                          padding: EdgeInsets.only(left: AppSpacing.xs),
                          child: Icon(
                            Icons.close,
                            size: AppSizes.iconSmallPlus,
                            color: AppColors.greyDark,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  style: const AppTextStyle(
                    fontSize: AppTypography.labelMedium,
                    color: AppColors.greyDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const AppTextStyle(
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      stockText,
                      style: AppTextStyle(
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                        color: isSoldOut ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
