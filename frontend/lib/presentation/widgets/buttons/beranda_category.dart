import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapCategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const HapHapCategoryPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: AppRadii.xxl,
          border: Border.all(
            // --- FULL PAKAI APP COLORS ---
            color: isSelected ? AppColors.primary : AppColors.greyLight,
            width: AppSizes.quarterStroke,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle(
            fontSize: AppTypography.bodyLarge,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            // --- FULL PAKAI APP COLORS ---
            color: isSelected ? AppColors.white : AppColors.greyDark,
          ),
        ),
      ),
    );
  }
}
