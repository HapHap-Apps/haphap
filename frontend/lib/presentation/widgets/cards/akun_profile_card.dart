import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String phoneNumber;
  final String? imageUrl;

  const HapHapProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = (imageUrl != null && imageUrl!.isNotEmpty)
        ? NetworkImage(imageUrl!) as ImageProvider
        : NetworkImage(
            'https://api.dicebear.com/9.x/adventurer/png?seed=${Uri.encodeComponent(name)}',
          );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: AppSizes.mediaLarge),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.xl,
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: AppSizes.hairline,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppSizes.avatarMedium,
            height: AppSizes.avatarMedium,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const AppTextStyle(
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  email,
                  style: const AppTextStyle(
                    fontSize: AppTypography.labelMedium,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  phoneNumber,
                  style: const AppTextStyle(
                    fontSize: AppTypography.labelMedium,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
