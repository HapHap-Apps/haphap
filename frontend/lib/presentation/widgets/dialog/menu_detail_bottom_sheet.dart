import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';

void showMenuDetailBottomSheet(
  BuildContext context, {
  required String imageUrl,
  required String title,
  required String description,
  required String price,
  required VoidCallback onAddToCart,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) {
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.sizeOf(context).height *
                AppLayout.bottomSheetMaxHeightFactor,
          ),
          child: Container(
            padding: const EdgeInsets.only(
              top: AppSpacing.xxl,
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
              bottom: AppSpacing.xxxl,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadii.largeTop,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final imageHeight = AppLayout.responsiveExtent(
                        constraints.maxWidth,
                        fraction: AppLayout.sheetImageFraction,
                        min: AppSizes.narrowPanel,
                        max: AppSizes.sheetImageHeight,
                      );
                      return ClipRRect(
                        borderRadius: AppRadii.lg,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: imageHeight,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: imageHeight,
                                    color: AppColors.surfaceBorder,
                                    child: const Icon(
                                      Icons.fastfood,
                                      color: AppColors.greyDark,
                                      size: AppSizes.avatarSmall,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: double.infinity,
                                height: imageHeight,
                                color: AppColors.surfaceBorder,
                                child: const Icon(
                                  Icons.fastfood,
                                  color: AppColors.greyDark,
                                  size: AppSizes.avatarSmall,
                                ),
                              ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    title,
                    style: const AppTextStyle(
                      fontSize: AppTypography.titleLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    description,
                    style: const AppTextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: AppColors.greyDark,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    price,
                    style: const AppTextStyle(
                      fontSize: AppTypography.titleLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  HapHapButton(
                    text: 'Tambahkan ke Keranjang - $price',
                    isExpanded: true,
                    onPressed: () {
                      onAddToCart();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
