import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/data/models/order_model.dart';

enum MerchantOrderStatus {
  menungguBayar,
  baru,
  sedangDisiapkan,
  siapDiambil,
  selesai,
  dibatalkan,
}

class HapHapMerchantOrderCard extends StatelessWidget {
  final MerchantOrderStatus status;
  final String customerName;
  final String orderId;
  final List<OrderItemModel> items;
  final String totalPrice;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onReady;
  final VoidCallback? onScanQR;

  const HapHapMerchantOrderCard({
    super.key,
    required this.status,
    required this.customerName,
    required this.orderId,
    required this.items,
    required this.totalPrice,
    this.onAccept,
    this.onReject,
    this.onReady,
    this.onScanQR,
  });

  @override
  Widget build(BuildContext context) {
    String badgeText = '';
    Color badgeColor = AppColors.transparent;
    Color badgeBgColor = AppColors.transparent;

    switch (status) {
      case MerchantOrderStatus.menungguBayar:
        badgeText = 'MENUNGGU BAYAR';
        badgeColor = AppColors.warningDark;
        badgeBgColor = AppColors.primarySurface;
        break;
      case MerchantOrderStatus.baru:
        badgeText = 'BARU';
        badgeColor = AppColors.error;
        badgeBgColor = AppColors.errorSurface;
        break;
      case MerchantOrderStatus.sedangDisiapkan:
        badgeText = 'SEDANG DISIAPKAN';
        badgeColor = AppColors.warningDark;
        badgeBgColor = AppColors.primarySurface;
        break;
      case MerchantOrderStatus.siapDiambil:
        badgeText = 'SIAP DIAMBIL';
        badgeColor = AppColors.info;
        badgeBgColor = AppColors.infoSurface;
        break;
      case MerchantOrderStatus.selesai:
        badgeText = 'SELESAI';
        badgeColor = AppColors.success;
        badgeBgColor = AppColors.successSurface;
        break;
      case MerchantOrderStatus.dibatalkan:
        badgeText = 'DIBATALKAN';
        badgeColor = AppColors.error;
        badgeBgColor = AppColors.errorSurface;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: AppSizes.hairline,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: AppRadii.md,
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyle(
                      fontSize: AppTypography.labelSmall,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: AppSizes.iconXs,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        customerName,
                        style: const AppTextStyle(
                          fontSize: AppTypography.bodyMedium,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      orderId.length > 8
                          ? '#${orderId.substring(0, 8)}'
                          : orderId,
                      style: const AppTextStyle(
                        fontSize: AppTypography.labelMedium,
                        color: AppColors.greyLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(
            color: AppColors.surfaceBorder,
            height: AppSizes.hairline,
            thickness: 1,
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: const AppTextStyle(
                              fontSize: AppTypography.labelMedium,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const AppTextStyle(
                                fontSize: AppTypography.labelMedium,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(
            color: AppColors.surfaceBorder,
            height: AppSizes.hairline,
            thickness: 1,
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pesanan',
                  style: AppTextStyle(
                    fontSize: AppTypography.labelMedium,
                    color: AppColors.greyDark,
                  ),
                ),
                Text(
                  totalPrice,
                  style: const AppTextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),

          if (status == MerchantOrderStatus.baru) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(
              color: AppColors.surfaceBorder,
              height: AppSizes.hairline,
              thickness: 1,
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: HapHapButton(
                      text: 'Tolak',
                      isOutline: true,
                      onPressed: onReject ?? () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: HapHapButton(
                      text: 'Terima',
                      onPressed: onAccept ?? () {},
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status == MerchantOrderStatus.sedangDisiapkan) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(
              color: AppColors.surfaceBorder,
              height: AppSizes.hairline,
              thickness: 1,
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: AppSizes.compactButtonWidth,
                  child: HapHapButton(
                    text: 'Siap Ambil',
                    isOutline: true,
                    onPressed: onReady ?? () {},
                  ),
                ),
              ),
            ),
          ] else if (status == MerchantOrderStatus.siapDiambil) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(
              color: AppColors.surfaceBorder,
              height: AppSizes.hairline,
              thickness: 1,
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: HapHapButton(
                  text: 'Scan QR Pengambil',
                  onPressed: onScanQR ?? () {},
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
