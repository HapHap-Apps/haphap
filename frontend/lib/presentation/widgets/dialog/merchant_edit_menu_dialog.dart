import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/inputs/text_fields.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';
import 'package:haphap_fe/data/services/menu_service.dart';

class HapHapEditMenuDialog extends StatefulWidget {
  final String menuItemId;
  final String initialName;
  final String initialPrice;
  final String initialDesc;

  const HapHapEditMenuDialog({
    super.key,
    required this.menuItemId,
    required this.initialName,
    required this.initialPrice,
    required this.initialDesc,
  });

  @override
  State<HapHapEditMenuDialog> createState() => _HapHapEditMenuDialogState();
}

class _HapHapEditMenuDialogState extends State<HapHapEditMenuDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);

    String cleanPrice = widget.initialPrice.replaceAll(RegExp(r'[^0-9]'), '');
    _priceController = TextEditingController(text: cleanPrice);

    _descController = TextEditingController(text: widget.initialDesc);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HapHapTextField(
          labelText: label,
          hintText: hint,
          controller: controller,
          keyboardType: keyboardType,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadii.xxl),
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Menu',
                style: AppTextStyle(
                  fontSize: AppTypography.titleLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              _buildInputField(
                label: 'Nama Menu',
                hint: 'Masukkan nama menu',
                controller: _nameController,
              ),
              _buildInputField(
                label: 'Harga',
                hint: 'Masukkan harga',
                controller: _priceController,
                keyboardType: TextInputType.number,
              ),
              _buildInputField(
                label: 'Deskripsi',
                hint: 'Masukkan deskripsi (opsional)',
                controller: _descController,
              ),

              const SizedBox(height: AppSpacing.lg),
              Center(
                child: HapHapButton(
                  text: 'Simpan Perubahan',
                  size: HapHapButtonSize.large,
                  isLoading: _isSaving,
                  onPressed: () async {
                    setState(() => _isSaving = true);
                    try {
                      final updateData = <String, dynamic>{};

                      if (_nameController.text.isNotEmpty) {
                        updateData['name'] = _nameController.text;
                      }
                      if (_descController.text.isNotEmpty) {
                        updateData['description'] = _descController.text;
                      }
                      final price = int.tryParse(_priceController.text);
                      if (price != null && price > 0) {
                        updateData['originalPrice'] = price;
                      }

                      await MenuService.updateMenu(
                        widget.menuItemId,
                        updateData,
                      );
                      if (!context.mounted) return;
                      setState(() => _isSaving = false);

                      AppSnackbar.showSuccess(
                        context,
                        'Menu berhasil diperbarui!',
                      );
                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!context.mounted) return;
                      setState(() => _isSaving = false);
                      AppSnackbar.showError(context, 'Gagal edit menu: $e');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
