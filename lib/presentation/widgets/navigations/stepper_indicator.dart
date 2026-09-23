import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapStepperIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  const HapHapStepperIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps * 2 - 1, (index) {
              final stepIndex = index ~/ 2;
              final isLine = index % 2 != 0;

              if (isLine) {
                final isCompleted = currentStep > stepIndex;
                return Expanded(
                  child: Container(
                    height: AppSizes.indicator,
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.greyLight,
                  ),
                );
              }

              final isCompleted = currentStep > stepIndex;
              final isActive = currentStep == stepIndex;

              return Container(
                width: AppSizes.iconLg,
                height: AppSizes.iconLg,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isCompleted
                      ? AppColors.primary
                      : AppColors.white,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? AppColors.primary
                        : AppColors.greyLight,
                    width: AppSizes.indicator,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: AppSizes.iconSmallPlus,
                        )
                      : Text(
                          '${stepIndex + 1}',
                          style: AppTextStyle(
                            color: isActive
                                ? AppColors.white
                                : AppColors.greyLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isActive = currentStep == index;
              return Expanded(
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyle(
                    fontSize: AppTypography.labelMedium,
                    color: isActive ? AppColors.black : AppColors.greyDark,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
