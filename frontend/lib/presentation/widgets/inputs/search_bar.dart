import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapSearchBar extends StatelessWidget {
  final String hintText;
  final String prefixIconPath;
  final String? suffixIconPath;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const HapHapSearchBar({
    super.key,
    required this.hintText,
    required this.prefixIconPath,
    this.suffixIconPath,
    this.onSuffixTap,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlineInputBorder(
      borderRadius: AppRadii.pill,
      borderSide: const BorderSide(
        color: AppColors.surfaceBorder,
        width: AppSizes.hairline,
      ),
    );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: AppSizes.compactControl),
      decoration: BoxDecoration(
        boxShadow: AppShadows.card,
        borderRadius: AppRadii.pill,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: const AppTextStyle(
          fontSize: AppTypography.bodyLarge,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.white,
          hintText: hintText,
          hintStyle: const AppTextStyle(
            color: AppColors.greyLight,
            fontSize: AppTypography.bodyLarge,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.none,
            horizontal: AppSpacing.xl,
          ),

          border: borderStyle,
          enabledBorder: borderStyle,
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadii.pill,
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: AppSizes.hairline,
            ),
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.md,
            ),
            child: SizedBox(
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              child: Center(child: SvgPicture.asset(prefixIconPath)),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: AppSizes.expandedButtonHeight,
            minHeight: AppSizes.compactControl,
          ),

          suffixIcon: suffixIconPath != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.lg,
                      left: AppSpacing.md,
                    ),
                    child: SizedBox(
                      width: AppSizes.iconSm,
                      height: AppSizes.iconSm,
                      child: Center(child: SvgPicture.asset(suffixIconPath!)),
                    ),
                  ),
                )
              : null,
          suffixIconConstraints: suffixIconPath != null
              ? const BoxConstraints(
                  minWidth: AppSizes.expandedButtonHeight,
                  minHeight: AppSizes.compactControl,
                )
              : null,
        ),
      ),
    );
  }
}
