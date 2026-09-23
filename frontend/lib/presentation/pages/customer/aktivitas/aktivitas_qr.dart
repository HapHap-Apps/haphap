import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HapHapQRCodeCard extends StatelessWidget {
  final String orderId;
  final String qrToken;
  final String? qrImagePath;

  const HapHapQRCodeCard({
    super.key,
    required this.orderId,
    required this.qrToken,
    this.qrImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lg,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: jsonEncode({'orderId': orderId, 'qrCode': qrToken}),
            version: QrVersions.auto,
            size: AppSizes.largeQrSize,
            backgroundColor: AppColors.white,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Tunjukkan ke kasir',
            style: AppTextStyle(
              fontSize: AppTypography.labelMedium,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
