import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/data/services/merchant_service.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';
import 'package:haphap_fe/presentation/widgets/inputs/dropdown_field.dart';
import 'package:haphap_fe/presentation/widgets/inputs/text_fields.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilMerchantPage extends StatefulWidget {
  const EditProfilMerchantPage({super.key});

  @override
  State<EditProfilMerchantPage> createState() => _EditProfilMerchantPageState();
}

class _EditProfilMerchantPageState extends State<EditProfilMerchantPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaTokoController;
  late TextEditingController _teleponController;
  late TextEditingController _alamatController;
  late TextEditingController _deskripsiController;
  late TextEditingController _jamBukaController;
  late TextEditingController _jamTutupController;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _avatarUrl;
  String? _selectedAvatarPath;
  String? _selectedCategory;

  String? _errorMessage;
  bool _isUnauthorized = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaTokoController = TextEditingController();
    _teleponController = TextEditingController();
    _alamatController = TextEditingController();
    _deskripsiController = TextEditingController();
    _jamBukaController = TextEditingController();
    _jamTutupController = TextEditingController();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isUnauthorized = false;
    });

    try {
      final merchant = await MerchantService.getMe();
      if (!mounted) return;
      setState(() {
        _namaTokoController.text = merchant.merchantName;
        _teleponController.text = merchant.phone ?? '';
        _alamatController.text = merchant.address ?? '';
        _deskripsiController.text = merchant.description ?? '';
        _jamBukaController.text = merchant.openTime ?? '';
        _jamTutupController.text = merchant.closeTime ?? '';
        _avatarUrl = merchant.avatar;
        _selectedCategory = merchant.categories.isNotEmpty
            ? merchant.categories.first
            : null;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (e.statusCode == 401) {
          _isUnauthorized = true;
          _errorMessage = 'Sesi kamu telah berakhir. Silakan login kembali.';
        } else {
          _errorMessage = e.message;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat profil toko. Periksa koneksi internet.';
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hour:$minute';
      });
    }
  }

  Future<void> _pickAvatar() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    final length = await pickedFile.length();
    if (length > 5 * 1024 * 1024) {
      if (mounted) AppSnackbar.showError(context, 'Ukuran file maksimal 5 MB');
      return;
    }

    setState(() {
      _selectedAvatarPath = pickedFile.path;
      _avatarUrl = pickedFile.path;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_jamBukaController.text.isEmpty || _jamTutupController.text.isEmpty) {
      AppSnackbar.showError(context, 'Waktu operasional harus diisi');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final fields = <String, String>{
        'merchantName': _namaTokoController.text,
        'phone': _teleponController.text,
        'address': _alamatController.text,
        'description': _deskripsiController.text,
        'openTime': _jamBukaController.text,
        'closeTime': _jamTutupController.text,
        if (_selectedCategory != null) 'categories': _selectedCategory!,
      };

      await MerchantService.updateMe(
        fields: fields,
        avatarPath: _selectedAvatarPath,
      );

      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Profil toko berhasil diperbarui!');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (e.statusCode == 401) {
        setState(() {
          _isUnauthorized = true;
          _errorMessage = 'Sesi kamu telah berakhir. Silakan login kembali.';
        });
      } else {
        AppSnackbar.showError(context, e.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppSnackbar.showError(
        context,
        'Gagal menyimpan profil. Periksa koneksi internet.',
      );
    }
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _deskripsiController.dispose();
    _jamBukaController.dispose();
    _jamTutupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: HapHapPageHeader(title: 'Edit Profil Toko'),
            ),
            Expanded(child: _buildBodyContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _buildProfilePicture()),
                  const SizedBox(height: AppSpacing.xxl),

                  const Text(
                    'Informasi Bisnis',
                    style: AppTextStyle(
                      fontSize: AppTypography.titleMedium,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  HapHapTextField(
                    labelText: 'Nama Toko',
                    hintText: 'Masukkan nama toko',
                    controller: _namaTokoController,
                    isRequired: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  HapHapTextField(
                    labelText: 'Telepon Bisnis',
                    hintText: 'Masukkan nomor telepon bisnis',
                    controller: _teleponController,
                    keyboardType: TextInputType.phone,
                    isRequired: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  HapHapTextField(
                    labelText: 'Alamat Bisnis',
                    hintText: 'Masukkan alamat lengkap',
                    controller: _alamatController,
                    isRequired: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  HapHapTextField(
                    labelText: 'Deskripsi',
                    hintText: 'Masukkan deskripsi bisnis (opsional)',
                    controller: _deskripsiController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  HapHapDropdownField(
                    labelText: 'Kategori Merchant',
                    hintText: 'Masukkan kategori',
                    value: _selectedCategory,
                    isRequired: true,
                    options: const [
                      'ROTI',
                      'RESTORAN',
                      'KAFE',
                      'KEBUTUHAN',
                      'JAJANAN',
                      'PENUTUP',
                    ],
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  const Text(
                    'Waktu Operasional',
                    style: AppTextStyle(
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(_jamBukaController),
                          child: IgnorePointer(
                            child: HapHapTextField(
                              labelText: 'Buka',
                              hintText: 'Masukkan jam buka',
                              controller: _jamBukaController,
                              isRequired: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(_jamTutupController),
                          child: IgnorePointer(
                            child: HapHapTextField(
                              labelText: 'Tutup',
                              hintText: 'Masukkan jam tutup',
                              controller: _jamTutupController,
                              isRequired: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: AppShadows.surfaceTop,
          ),
          child: HapHapButton(
            text: 'Simpan',
            isExpanded: true,
            isLoading: _isSaving,
            onPressed: _saveProfile,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isUnauthorized ? Icons.lock_outline : Icons.error_outline,
              size: AppSizes.touchTarget,
              color: AppColors.greyDark,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const AppTextStyle(
                color: AppColors.greyDark,
                fontSize: AppTypography.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            HapHapButton(
              text: _isUnauthorized ? 'Login Ulang' : 'Coba Lagi',
              onPressed: () {
                if (_isUnauthorized) {
                  context.go(AppRoutes.login);
                } else {
                  _fetchProfile();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    final isLocalPath = _selectedAvatarPath != null;

    return GestureDetector(
      onTap: _isSaving ? null : _pickAvatar,
      child: Stack(
        children: [
          Container(
            width: AppSizes.profileImage,
            height: AppSizes.profileImage,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.divider,
              border: Border.all(
                color: AppColors.white,
                width: AppSizes.progressIndicator,
              ),
              boxShadow: AppShadows.card,
              image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                  ? DecorationImage(
                      image: isLocalPath
                          ? NetworkImage(_avatarUrl!) as ImageProvider
                          : NetworkImage(_avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _avatarUrl == null || _avatarUrl!.isEmpty
                ? const Icon(
                    Icons.store,
                    size: AppSizes.emptyStateIcon,
                    color: AppColors.grey,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: AppSizes.iconLg,
              height: AppSizes.iconLg,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: AppSizes.indicator,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: AppSizes.iconXs,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
