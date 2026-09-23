import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapMerchantMenuItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String price;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HapHapMerchantMenuItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      color: AppColors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: AppRadii.lg,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: AppSizes.mediaSmall,
                    height: AppSizes.mediaSmall,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: AppSizes.mediaSmall,
                        height: AppSizes.mediaSmall,
                        color: AppColors.surfaceMuted,
                        child: const Icon(
                          Icons.restaurant,
                          color: AppColors.greyDark,
                          size: AppSizes.iconLargePlus,
                        ),
                      );
                    },
                  )
                : Container(
                    width: AppSizes.mediaSmall,
                    height: AppSizes.mediaSmall,
                    color: AppColors.surfaceMuted,
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.greyDark,
                      size: AppSizes.iconLargePlus,
                    ),
                  ),
          ),

          const SizedBox(width: AppSpacing.lg),

          Expanded(
            child: SizedBox(
              height: AppSizes.mediaSmall,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const AppTextStyle(
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: onEdit,
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(
                          Icons.edit,
                          size: AppSizes.iconSm,
                          color: AppColors.greyDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      GestureDetector(
                        onTap: onDelete,
                        behavior: HitTestBehavior.opaque,
                        child: const Icon(
                          Icons.delete,
                          size: AppSizes.iconSm,
                          color: AppColors.greyDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    description,
                    style: const AppTextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: AppColors.greyDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    price,
                    style: const AppTextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
