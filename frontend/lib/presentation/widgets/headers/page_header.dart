import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Color titleColor;
  final double fontSize;

  const HapHapPageHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    this.showBackButton = true,
    this.titleColor = AppColors.black,
    this.fontSize = AppTypography.titleLarge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.compactTouchTarget),
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton)
            GestureDetector(
              onTap:
                  onBackPressed ??
                  () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      debugPrint('Ini halaman paling awal, tidak bisa back!');
                    }
                  },
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(
                  right: AppSpacing.lg,
                  top: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: AppSizes.iconLargeMinus,
                ),
              ),
            ),

          Expanded(
            child: Text(
              title,
              style: AppTextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
