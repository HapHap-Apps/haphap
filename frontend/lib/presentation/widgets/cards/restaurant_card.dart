import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapRestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String distanceTime;
  final String restaurantName;
  final String ratingText;

  const HapHapRestaurantCard({
    super.key,
    required this.imageUrl,
    required this.distanceTime,
    required this.restaurantName,
    required this.ratingText,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = AppLayout.responsiveExtent(
          constraints.maxWidth,
          fraction: AppLayout.cardImageFraction,
          min: AppSizes.thumbnailCompact,
          max: AppSizes.mediaLarge,
        );

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: AppSizes.restaurantCardHeight,
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
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: AppRadii.lgRadius,
                  bottomLeft: AppRadii.lgRadius,
                ),
                child: _buildImage(imageWidth),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        distanceTime,
                        style: const AppTextStyle(
                          fontSize: AppTypography.labelMedium,
                          color: AppColors.greyDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        restaurantName,
                        style: const AppTextStyle(
                          fontSize: AppTypography.bodyLarge,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: AppSizes.iconXs,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              ratingText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const AppTextStyle(
                                fontSize: AppTypography.labelMedium,
                                color: AppColors.greyDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(double width) {
    final isValidUrl =
        imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    if (isValidUrl) {
      return Image.network(
        imageUrl,
        width: width,
        height: AppSizes.restaurantCardHeight,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(width),
      );
    }
    return _placeholder(width);
  }

  Widget _placeholder(double width) {
    return Container(
      width: width,
      height: AppSizes.restaurantCardHeight,
      color: AppColors.surfaceBorder,
      child: const Icon(
        Icons.storefront,
        color: AppColors.greyDark,
        size: AppSizes.iconXl,
      ),
    );
  }
}
