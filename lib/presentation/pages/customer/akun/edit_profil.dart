import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';
import 'package:haphap_fe/presentation/widgets/inputs/text_fields.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/data/services/user_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  late TextEditingController _namaController;
  late TextEditingController _teleponController;
  late TextEditingController _emailController;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _avatarUrl;
  String? _selectedAvatarPath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _teleponController = TextEditingController();
    _emailController = TextEditingController();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = await UserService.getMe();
      if (!mounted) return;
      setState(() {
        _namaController.text = user.name;
        _teleponController.text = user.phone ?? '';
        _emailController.text = user.email;
        _avatarUrl = user.avatar;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackbar.showError(context, 'Gagal memuat profil: $e');
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
    setState(() => _isSaving = true);
    try {
      await UserService.updateMe(
        name: _namaController.text,
        phone: _teleponController.text,
        email: _emailController.text,
        avatarPath: _selectedAvatarPath,
      );
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Profil berhasil diperbarui');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                      child: HapHapPageHeader(title: 'Edit Profil'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildProfilePicture(),
                    const SizedBox(height: AppSpacing.xxl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: Column(
                        children: [
                          HapHapTextField(
                            labelText: 'Nama Lengkap',
                            hintText: 'Masukkan nama lengkap',
                            controller: _namaController,
                            isRequired: true,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          HapHapTextField(
                            labelText: 'Nomor Telepon',
                            hintText: 'Masukkan nomor telepon',
                            controller: _teleponController,
                            isRequired: true,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          HapHapTextField(
                            labelText: 'Alamat Email',
                            hintText: 'Masukkan alamat email',
                            controller: _emailController,
                            isRequired: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.bottomClearance),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: _isSaving ? null : _pickAvatar,
          child: ClipRRect(
            borderRadius: AppRadii.pill,
            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                ? Image.network(
                    _avatarUrl!,
                    width: AppSizes.profileImage,
                    height: AppSizes.profileImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderAvatar(),
                  )
                : _buildPlaceholderAvatar(),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isSaving ? null : _pickAvatar,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: AppSizes.strongStroke,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.white,
                size: AppSizes.iconXs,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: AppSizes.profileImage,
      height: AppSizes.profileImage,
      color: AppColors.primary.withValues(alpha: 0.2),
      child: const Icon(
        Icons.person,
        size: AppSizes.emptyStateIcon,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildBottomButton() {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.lg,
        bottom: bottomSafeArea > AppSpacing.none
            ? bottomSafeArea
            : AppSpacing.xxl,
      ),
      color: AppColors.white,
      child: HapHapButton(
        text: 'Simpan',
        isExpanded: true,
        isLoading: _isSaving,
        onPressed: _saveProfile,
      ),
    );
  }
}
