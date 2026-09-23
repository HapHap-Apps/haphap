import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String> tabs;

  const HapHapTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.tabs = const ['Proses', 'Riwayat', 'Lainnya'],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(tabs.length, (index) {
        return Row(
          children: [
            _buildTabItem(index, tabs[index]),
            if (index < tabs.length - 1) const SizedBox(width: AppSpacing.xxxl),
          ],
        );
      }),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                title,
                style: AppTextStyle(
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.black : AppColors.greyDark,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: AppSizes.progressIndicator,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.transparent,
                borderRadius: AppRadii.xs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
