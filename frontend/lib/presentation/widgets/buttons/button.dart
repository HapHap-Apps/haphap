import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

enum HapHapButtonSize { tiny, small, medium, large }

class HapHapButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final HapHapButtonSize size;
  final bool isOutline;
  final bool isText;
  final bool isLoading;
  final bool isExpanded;
  final bool isDanger;

  const HapHapButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = HapHapButtonSize.tiny,
    this.isOutline = false,
    this.isText = false,
    this.isLoading = false,
    this.isExpanded = false,
    this.isDanger = false,
  });

  double get _buttonWidth {
    if (isExpanded) return double.infinity;
    switch (size) {
      case HapHapButtonSize.tiny:
        return AppSizes.tinyButtonWidth;
      case HapHapButtonSize.small:
        return AppSizes.statsCard;
      case HapHapButtonSize.medium:
        return AppSizes.mediumButtonWidth;
      case HapHapButtonSize.large:
        return AppSizes.designContentWidth;
    }
  }

  double get _buttonHeight =>
      isExpanded ? AppSizes.expandedButtonHeight : AppSizes.iconLg;

  double get _fontSize {
    if (isExpanded || size == HapHapButtonSize.large) {
      return AppTypography.bodyLarge;
    }
    return AppTypography.labelMedium;
  }

  Color get _solidColor => isDanger ? AppColors.error : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: AppRadii.sheet);

    final Widget child = isLoading
        ? SizedBox(
            width: isExpanded ? AppSizes.iconMediumPlus : AppSizes.iconXs,
            height: isExpanded ? AppSizes.iconMediumPlus : AppSizes.iconXs,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.mediumStroke,
              color: isOutline ? _solidColor : AppColors.white,
            ),
          )
        : Text(
            text,
            style: AppTextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
            ),
          );

    if (isText) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: _solidColor,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isExpanded ? double.infinity : _buttonWidth,
      ),
      child: SizedBox(
        width: double.infinity,
        height: _buttonHeight,
        child: isOutline
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: AppSizes.thinStroke,
                  ),
                  shape: shape,
                  padding: EdgeInsets.zero,
                ),
                child: child,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _solidColor,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: _solidColor.withValues(alpha: 0.6),
                  elevation: AppElevations.none,
                  shape: shape,
                  padding: EdgeInsets.zero,
                ),
                child: child,
              ),
      ),
    );
  }
}
