import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapCategoryButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const HapHapCategoryButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.categoryButton,
            height: AppSizes.categoryButton,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadii.md,
              border: Border.all(
                color: AppColors.surfaceBorder,
                width: AppSizes.hairline,
              ),
              boxShadow: AppShadows.card,
            ),
            child: Center(
              child: SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: iconColor != null
                      ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                      : null,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            label,
            style: const AppTextStyle(
              fontSize: AppTypography.labelMedium,
              fontWeight: FontWeight.w500,
              color: AppColors.greyDark,
            ),
          ),
        ],
      ),
    );
  }
}
