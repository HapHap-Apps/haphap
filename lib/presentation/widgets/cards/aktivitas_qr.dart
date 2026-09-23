import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapQRCodeCard extends StatelessWidget {
  final String qrToken;

  const HapHapQRCodeCard({super.key, required this.qrToken});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.qrCardWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadii.lg,
              boxShadow: AppShadows.card,
            ),
            child: QrImageView(
              data: qrToken,
              version: QrVersions.auto,
              size: AppSizes.qrCardSize,
              backgroundColor: AppColors.white,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          const Text(
            'Tunjukkan ke kasir',
            style: AppTextStyle(
              fontSize: AppTypography.labelMedium,
              color: AppColors.greyDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
