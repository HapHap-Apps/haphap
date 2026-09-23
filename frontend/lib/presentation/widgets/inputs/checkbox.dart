import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const HapHapCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: AppSizes.iconSm,
            height: AppSizes.iconSm,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : AppColors.transparent,
              borderRadius: AppRadii.sm,
              border: Border.all(
                color: AppColors.primary,
                width: AppSizes.thinStroke,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: AppSizes.iconCompact,
                    color: AppColors.white,
                  )
                : null,
          ),

          const SizedBox(width: AppSpacing.sm),

          Text(
            label,
            style: const AppTextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: FontWeight.w500,
              color: AppColors.greyDark,
            ),
          ),
        ],
      ),
    );
  }
}
