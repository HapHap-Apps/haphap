import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';

class HapHapRiwayatCard extends StatelessWidget {
  final String imageUrl;
  final String dateStatusText;
  final String restaurantName;
  final String price;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const HapHapRiwayatCard({
    super.key,
    required this.imageUrl,
    required this.dateStatusText,
    required this.restaurantName,
    required this.price,
    this.buttonText,
    this.onButtonPressed,
  });

  Widget _placeholder([double extent = AppSizes.mediaLarge]) {
    return Container(
      width: extent,
      height: extent,
      decoration: BoxDecoration(
        color: AppColors.surfaceBorder,
        borderRadius: AppRadii.lg,
      ),
      child: const Icon(
        Icons.storefront_outlined,
        size: AppSizes.iconXl,
        color: AppColors.greyDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageExtent = AppLayout.responsiveExtent(
          constraints.maxWidth,
          fraction: AppLayout.cardImageFraction,
          min: AppSizes.thumbnailCompact,
          max: AppSizes.mediaLarge,
        );

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: AppSizes.narrowPanel),
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
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadii.lg,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: imageExtent,
                        height: imageExtent,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(imageExtent),
                      )
                    : _placeholder(imageExtent),
              ),

              const SizedBox(width: AppSpacing.lg),

              Expanded(
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

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      restaurantName,
                      style: const AppTextStyle(
                        fontSize: AppTypography.titleMedium,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          price,
                          style: const AppTextStyle(
                            fontSize: AppTypography.labelMedium,
                            color: AppColors.greyDark,
                          ),
                        ),

                        if (buttonText != null && onButtonPressed != null)
                          HapHapButton(
                            text: buttonText!,
                            onPressed: onButtonPressed,
                            size: HapHapButtonSize.tiny,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
