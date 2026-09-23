import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapOnboardingNextButton extends StatelessWidget {
  final double? progress;
  final VoidCallback onPressed;
  final double size;

  const HapHapOnboardingNextButton({
    super.key,
    required this.progress,
    required this.onPressed,
    this.size = AppSizes.mediaLarge,
  });

  @override
  Widget build(BuildContext context) {
    final double strokeThickness = size * 0.09;
    final double innerSize = size * 0.65;
    final double iconSize = size * 0.3;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeThickness,
              backgroundColor: AppColors.grey300,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == null ? AppColors.grey500 : AppColors.primary,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),

          SizedBox(
            width: innerSize,
            height: innerSize,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                elevation: AppElevations.none,
              ),
              child: Icon(Icons.arrow_forward, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}

class HapHapSkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isWhiteVariant;

  const HapHapSkipButton({
    super.key,
    required this.onPressed,
    this.isWhiteVariant = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWhiteVariant ? AppColors.white : AppColors.primary;

    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(AppColors.transparent),
        foregroundColor: WidgetStateProperty.all(color),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),
        textStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppTextStyle(
              fontSize: AppTypography.bodyLarge,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: color,
            );
          }
          return const AppTextStyle(
            fontSize: AppTypography.bodyLarge,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Lewati'),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.arrow_forward, size: AppSizes.iconSm, color: color),
        ],
      ),
    );
  }
}
