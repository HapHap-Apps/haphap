import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void showError(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.error);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.success);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.primary);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const AppTextStyle(
            fontSize: AppTypography.bodyMedium,
            color: AppColors.white,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.none,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
