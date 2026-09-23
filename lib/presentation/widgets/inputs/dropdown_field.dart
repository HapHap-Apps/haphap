import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapDropdownField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String? value;
  final List<String> options;
  final Function(String) onSelected;
  final bool isRequired;

  const HapHapDropdownField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.options,
    required this.onSelected,
    this.value,
    this.isRequired = false,
  });

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: AppRadii.xxlRadius,
              topRight: AppRadii.xxlRadius,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: AppSizes.iconXl,
                height: AppSizes.progressIndicator,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: AppRadii.xs,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Pilih $labelText',
                style: const AppTextStyle(
                  fontSize: AppTypography.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = option == value;
                    return InkWell(
                      onTap: () {
                        onSelected(option);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.greyLight.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: AppTextStyle(
                                fontSize: AppTypography.bodyLarge,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.black,
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check, color: AppColors.primary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: labelText,
            style: const AppTextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: FontWeight.w500,
              color: AppColors.greyDark,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: AppTextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        InkWell(
          onTap: () => _showBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.greyLight,
                  width: AppSizes.hairline,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? hintText,
                  style: AppTextStyle(
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: value != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: value != null
                        ? AppColors.black
                        : AppColors.greyLight,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.greyDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
