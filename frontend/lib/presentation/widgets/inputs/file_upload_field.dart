import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapFileUploadField extends StatelessWidget {
  final String labelText;
  final String maxSizeText;
  final String formatText;
  final String? selectedFileName;
  final VoidCallback onFileSelected;
  final VoidCallback onClear;
  final bool isRequired;

  const HapHapFileUploadField({
    super.key,
    required this.labelText,
    this.maxSizeText = 'Maksimal Size * 5 MB',
    this.formatText = 'Format file: .pdf, .jpg, .png',
    this.selectedFileName,
    required this.onFileSelected,
    required this.onClear,
    this.isRequired = false,
  });

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
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: selectedFileName == null ? onFileSelected : null,
          borderRadius: AppRadii.md,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xxl,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: AppRadii.md,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: AppSizes.hairline,
              ),
            ),
            child: selectedFileName != null
                ? Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          selectedFileName!,
                          style: const AppTextStyle(
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: onClear,
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.error,
                          size: AppSizes.iconSm,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.upload_file,
                          color: AppColors.primary,
                          size: AppSizes.iconLargeMinus,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Telusuri file',
                        style: AppTextStyle(
                          fontSize: AppTypography.bodyMedium,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Format yang didukung: .pdf, .jpeg, .jpg, .png\nUkuran maksimal: 5MB',
                        textAlign: TextAlign.center,
                        style: AppTextStyle(
                          fontSize: AppTypography.labelMedium,
                          color: AppColors.greyDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
