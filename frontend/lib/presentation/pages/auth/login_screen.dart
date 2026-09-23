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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    return null;
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (!response.success) {
        AppSnackbar.showError(context, response.message);
        return;
      }

      final token = response.data?.token;

      if (token == null || token.isEmpty) {
        AppSnackbar.showError(context, 'Token tidak ditemukan dari server.');
        return;
      }

      final role = response.data?.role ?? 'USER';
      await TokenManager.saveSession(
        token: token,
        role: role,
        remember: _rememberMe,
      );

      if (!mounted) return;

      AppSnackbar.showSuccess(context, 'Login berhasil! Selamat datang.');

      if (role == 'ADMIN') {
        context.go(AppRoutes.adminBeranda);
      } else if (role == 'MERCHANT') {
        context.go(AppRoutes.merchantBeranda);
      } else {
        context.go(AppRoutes.beranda);
      }
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

  Future<void> _handleGoogleLogin() async {
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
        remember: _rememberMe,
      );

      if (!mounted) return;

      AppSnackbar.showSuccess(
        context,
        'Login Google berhasil! Selamat datang.',
      );

      if (role == 'ADMIN') {
        context.go(AppRoutes.adminBeranda);
      } else if (role == 'MERCHANT') {
        context.go(AppRoutes.merchantBeranda);
      } else {
        context.go(AppRoutes.beranda);
      }
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
                      'Masuk ke akun HapHapmu sekarang dan jadi pahlawan buat bumi dan perut laparmu.',
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
                key: const Key('login_bottom_panel'),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: AppRadii.sheetRadius,
                  ),
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

                      const SizedBox(height: AppSpacing.lg),

                      Row(
                        children: [
                          SizedBox(
                            width: AppSizes.iconMd,
                            height: AppSizes.iconMd,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.xs,
                              ),
                              side: const BorderSide(color: AppColors.grey),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Text(
                            'Ingat Saya',
                            style: AppTextStyle(
                              fontSize: AppTypography.bodyMedium,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      HapHapButton(
                        text: 'Masuk',
                        isExpanded: true,
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
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
                            onPressed: _isLoading ? null : _handleGoogleLogin,
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
                          onTap: () => context.push(AppRoutes.register),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Baru di HapHap? ',
                              style: AppTextStyle(
                                fontSize: AppTypography.bodyMedium,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Daftar sekarang',
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
