import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/inputs/text_fields.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';
import 'package:haphap_fe/data/services/order_service.dart';
import 'package:haphap_fe/core/network/api_client.dart';

class HapHapScanQRDialog extends StatefulWidget {
  final String orderId;

  const HapHapScanQRDialog({super.key, required this.orderId});

  @override
  State<HapHapScanQRDialog> createState() => _HapHapScanQRDialogState();
}

class _HapHapScanQRDialogState extends State<HapHapScanQRDialog> {
  final TextEditingController _qrController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitQR() async {
    if (_qrController.text.isEmpty) {
      AppSnackbar.showError(context, 'Kode QR tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await OrderService.scanOrder(widget.orderId, _qrController.text);
      if (!mounted) return;
      setState(() => _isLoading = false);

      AppSnackbar.showSuccess(context, 'Pesanan berhasil diselesaikan!');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackbar.showError(context, 'Gagal verifikasi QR: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackbar.showError(context, 'Gagal verifikasi QR: $e');
    }
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadii.xxl),
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan QR Pengambil',
              style: AppTextStyle(
                fontSize: AppTypography.titleLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Masukkan kode unik QR dari pembeli untuk memverifikasi pengambilan pesanan.',
              style: AppTextStyle(
                fontSize: AppTypography.bodyMedium,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            HapHapTextField(
              labelText: 'Kode QR',
              hintText: 'Masukkan kode QR',
              controller: _qrController,
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: HapHapButton(
                text: 'Verifikasi Pesanan',
                size: HapHapButtonSize.large,
                isLoading: _isLoading,
                onPressed: _submitQR,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
