import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapOrderItem {
  final String name;
  final String description;
  final String price;
  final int quantity;

  const HapHapOrderItem({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });
}

class HapHapDetailPesananCard extends StatelessWidget {
  final String restaurantName;
  final String restaurantLogoUrl;
  final List<HapHapOrderItem> items;

  const HapHapDetailPesananCard({
    super.key,
    required this.restaurantName,
    required this.restaurantLogoUrl,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: AppSizes.hairline,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: restaurantLogoUrl.isNotEmpty
                    ? Image.network(
                        restaurantLogoUrl,
                        width: AppSizes.iconLg,
                        height: AppSizes.iconLg,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: AppSizes.iconLg,
                            height: AppSizes.iconLg,
                            color: AppColors.surfaceMuted,
                            child: const Icon(
                              Icons.storefront,
                              color: AppColors.greyDark,
                              size: AppSizes.iconXs,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: AppSizes.iconLg,
                        height: AppSizes.iconLg,
                        color: AppColors.surfaceMuted,
                        child: const Icon(
                          Icons.storefront,
                          color: AppColors.greyDark,
                          size: AppSizes.iconXs,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                restaurantName,
                style: const AppTextStyle(
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          ...List.generate(items.length, (index) {
            final item = items[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - AppSpacing.hairline
                    ? AppSpacing.none
                    : AppSpacing.lg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const AppTextStyle(
                            fontSize: AppTypography.labelMedium,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.description,
                          style: const AppTextStyle(
                            fontSize: AppTypography.labelMedium,
                            color: AppColors.greyDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.lg),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.price,
                        style: const AppTextStyle(
                          fontSize: AppTypography.labelMedium,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'x${item.quantity}',
                        style: const AppTextStyle(
                          fontSize: AppTypography.labelMedium,
                          color: AppColors.greyDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
