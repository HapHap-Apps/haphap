import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/data/services/menu_service.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';

class HapHapDeleteMenuDialog extends StatefulWidget {
  final String menuName;
  final String menuItemId;

  const HapHapDeleteMenuDialog({
    super.key,
    required this.menuName,
    required this.menuItemId,
  });

  @override
  State<HapHapDeleteMenuDialog> createState() => _HapHapDeleteMenuDialogState();
}

class _HapHapDeleteMenuDialogState extends State<HapHapDeleteMenuDialog> {
  bool _isDeleting = false;

  Future<void> _onDelete() async {
    setState(() => _isDeleting = true);

    try {
      await MenuService.deleteMenu(widget.menuItemId);
      if (!mounted) return;

      AppSnackbar.showSuccess(
        context,
        '"${widget.menuName}" berhasil dihapus.',
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      AppSnackbar.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      AppSnackbar.showError(context, 'Gagal menghapus menu. Coba lagi.');
    }
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
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: AppSizes.touchTarget,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Hapus Menu?',
              style: AppTextStyle(
                fontSize: AppTypography.titleLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Yakin mau hapus "${widget.menuName}"? Data yang sudah dihapus tidak bisa dikembalikan.',
              textAlign: TextAlign.center,
              style: const AppTextStyle(
                fontSize: AppTypography.bodyMedium,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Row(
              children: [
                Expanded(
                  child: HapHapButton(
                    text: 'Batal',
                    isOutline: true,
                    onPressed: _isDeleting
                        ? () {}
                        : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _isDeleting
                      ? const Center(
                          child: SizedBox(
                            width: AppSizes.iconMd,
                            height: AppSizes.iconMd,
                            child: CircularProgressIndicator(
                              color: AppColors.error,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : HapHapButton(
                          text: 'Hapus',
                          isDanger: true,
                          onPressed: _onDelete,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
