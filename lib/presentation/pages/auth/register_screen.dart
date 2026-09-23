import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/core/network/token_manager.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/data/services/auth_service.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';
import 'package:haphap_fe/presentation/widgets/inputs/text_fields.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP tidak boleh kosong.';
    }
    final phoneRegex = RegExp(r'^[0-9+\-\s]{8,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Format nomor HP tidak valid.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Format email tidak valid.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong.';
    if (value.length < 8) return 'Password minimal 8 karakter.';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong.';
    }
    if (value != _passwordController.text) return 'Password tidak cocok.';
    return null;
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (!response.success) {
        AppSnackbar.showError(context, response.message);
        return;
      }

      AppSnackbar.showSuccess(context, 'Akun berhasil dibuat! Silakan masuk.');
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        'Terjadi kesalahan saat menghubungi server.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isLoading = true);

    try {
      final idToken = await AuthService.signInWithGoogle();

      if (!mounted) return;

      if (idToken == null) return;

      final response = await ApiClient.post('/auth/google', {
        'idToken': idToken,
      });

      if (!mounted) return;

      final accessToken = response['data']?['accessToken'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.showError(
          context,
          response['message'] as String? ??
              'Token tidak ditemukan dari server.',
        );
        return;
      }

      final role = response['data']?['role'] as String? ?? 'USER';
      await TokenManager.saveSession(
        token: accessToken,
        role: role,
        remember: true,
      );

      if (!mounted) return;

      AppSnackbar.showSuccess(
        context,
        'Akun Google berhasil terhubung! Selamat datang.',
      );
      context.go(AppRoutes.beranda);
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, e.message);
    } on GoogleAuthException catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        'Terjadi kesalahan saat login dengan Google.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.loose,
                  left: AppLayout.pagePadding(context),
                  right: AppLayout.pagePadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Waktunya Ngunyah!',
                      style: AppTextStyle(
                        fontSize: AppTypography.displaySmall,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Buat akun HapHapmu dan mulai selamatkan makanan bareng kami!',
                      textAlign: TextAlign.center,
                      style: AppTextStyle(
                        fontSize: AppTypography.bodyLarge,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.loose)),

            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                key: const Key('register_bottom_panel'),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadii.sheetTop,
                ),
                padding: EdgeInsets.fromLTRB(
                  AppLayout.pagePadding(context),
                  AppSpacing.xxxl,
                  AppLayout.pagePadding(context),
                  AppSpacing.none,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HapHapTextField(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama',
                        controller: _nameController,
                        isPassword: false,
                        isRequired: true,
                        validator: _validateName,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      HapHapTextField(
                        labelText: 'Nomor HP',
                        hintText: 'Masukkan nomor telepon',
                        controller: _phoneController,
                        isPassword: false,
                        isRequired: true,
                        validator: _validatePhone,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      HapHapTextField(
                        labelText: 'Email',
                        hintText: 'Masukkan email',
                        controller: _emailController,
                        isPassword: false,
                        isRequired: true,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      HapHapTextField(
                        labelText: 'Password',
                        hintText: 'Masukkan password',
                        controller: _passwordController,
                        isPassword: true,
                        isRequired: true,
                        validator: _validatePassword,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      HapHapTextField(
                        labelText: 'Konfirmasi Password',
                        hintText: 'Masukkan konfirmasi password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        isRequired: true,
                        validator: _validateConfirmPassword,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      HapHapButton(
                        text: 'Daftar',
                        isExpanded: true,
                        isLoading: _isLoading,
                        onPressed: _handleRegister,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.greyLight)),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Text(
                                'Atau Lanjut Dengan',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: AppTextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  color: AppColors.greyDark,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.greyLight)),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      Center(
                        child: Container(
                          width: AppSizes.avatarSmall,
                          height: AppSizes.avatarSmall,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                            boxShadow: AppShadows.card,
                          ),
                          child: IconButton(
                            onPressed: _isLoading
                                ? null
                                : _handleGoogleRegister,
                            icon: Image.asset(
                              'assets/images/google_logo.png',
                              width: AppSizes.iconXl,
                              height: AppSizes.iconXl,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      Center(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Sudah punya akun? ',
                              style: AppTextStyle(
                                fontSize: AppTypography.bodyMedium,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Masuk',
                                  style: AppTextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SafeArea(
                        top: false,
                        child: SizedBox(height: AppSpacing.md),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
