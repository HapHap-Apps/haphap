import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class HapHapRincianPembayaran extends StatelessWidget {
  final String paymentMethod;
  final String totalPrice;
  final String orderNumber;
  final String paymentTime;
  final String completionTime;

  const HapHapRincianPembayaran({
    super.key,
    required this.paymentMethod,
    required this.totalPrice,
    required this.orderNumber,
    required this.paymentTime,
    required this.completionTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: AppSizes.avatarCompact,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: _cardDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRowItem('Metode Pembayaran', paymentMethod),
              _buildRowItem('Total Harga', totalPrice),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _buildRowItem('No. Pesanan', orderNumber),
              const SizedBox(height: AppSpacing.sm),
              _buildRowItem('Waktu Pembayaran', paymentTime),
              const SizedBox(height: AppSpacing.sm),
              _buildRowItem('Waktu Pesanan Selesai', completionTime),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: AppRadii.lg,
      border: Border.all(
        color: AppColors.surfaceBorder,
        width: AppSizes.hairline,
      ),
      boxShadow: AppShadows.card,
    );
  }

  Widget _buildRowItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const AppTextStyle(
            fontSize: AppTypography.labelMedium,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const AppTextStyle(
            fontSize: AppTypography.labelMedium,
            color: AppColors.greyDark,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
