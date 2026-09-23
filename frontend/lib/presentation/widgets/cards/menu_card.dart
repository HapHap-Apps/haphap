import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/dialog/menu_detail_bottom_sheet.dart';

class HapHapMenuCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String price;
  final int stockCount;
  final int cartCount;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const HapHapMenuCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    required this.stockCount,
    this.cartCount = 0,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = stockCount == 0;

    return GestureDetector(
      onTap: () {
        showMenuDetailBottomSheet(
          context,
          imageUrl: imageUrl,
          title: title,
          description: description,
          price: price,
          onAddToCart: onAdd,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageExtent = AppLayout.responsiveExtent(
            constraints.maxWidth,
            fraction: AppLayout.menuImageFraction,
            min: AppSizes.avatarMedium,
            max: AppSizes.mediaSmall,
          );

          return Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: AppSizes.menuCardHeight,
            ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: AppRadii.lg,
                  child: _buildImage(isOutOfStock, imageExtent),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                          _buildStockIndicator(isOutOfStock),
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
                      LayoutBuilder(
                        builder: (context, actionConstraints) {
                          final priceText = Text(
                            price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const AppTextStyle(
                              fontSize: AppTypography.bodyMedium,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          );
                          final actions = _buildActionButtons(isOutOfStock);

                          if (actionConstraints.maxWidth <
                              AppLayout.compactActionRow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                priceText,
                                const SizedBox(height: AppSpacing.sm),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: actions,
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: priceText),
                              const SizedBox(width: AppSpacing.sm),
                              actions,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(bool isOutOfStock, double extent) {
    final isValidUrl =
        imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    Widget imageWidget = isValidUrl
        ? Image.network(
            imageUrl,
            width: extent,
            height: extent,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(extent),
          )
        : _imagePlaceholder(extent);

    if (isOutOfStock) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
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
        ]),
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _imagePlaceholder(double extent) {
    return Container(
      width: extent,
      height: extent,
      color: AppColors.surfaceBorder,
      child: const Icon(
        Icons.fastfood,
        color: AppColors.greyDark,
        size: AppSizes.iconLg,
      ),
    );
  }

  Widget _buildStockIndicator(bool isOutOfStock) {
    if (isOutOfStock) {
      return const Text(
        'Out of\nStock',
        textAlign: TextAlign.right,
        style: AppTextStyle(
          fontSize: AppTypography.labelMedium,
          fontWeight: FontWeight.bold,
          color: AppColors.error,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.error,
          height: AppTypography.lineHeightTight,
        ),
      );
    } else if (stockCount <= 5) {
      return Text(
        '$stockCount left',
        style: const AppTextStyle(
          fontSize: AppTypography.labelMedium,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primary,
        ),
      );
    }
    return Text(
      '$stockCount left',
      style: const AppTextStyle(
        fontSize: AppTypography.labelMedium,
        fontWeight: FontWeight.bold,
        color: AppColors.greyDark,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.greyDark,
      ),
    );
  }

  Widget _buildActionButtons(bool isOutOfStock) {
    if (isOutOfStock) return const SizedBox(height: AppSpacing.xxl);

    Widget circleButton(IconData icon, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: AppSizes.iconMd,
          height: AppSizes.iconMd,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white, size: AppSizes.iconXs),
        ),
      );
    }

    if (cartCount == 0) {
      return circleButton(Icons.add, onAdd);
    } else {
      return Row(
        children: [
          circleButton(Icons.remove, onRemove),
          const SizedBox(width: AppSpacing.md),
          Text(
            '$cartCount',
            style: const AppTextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          circleButton(Icons.add, onAdd),
        ],
      );
    }
  }
}
