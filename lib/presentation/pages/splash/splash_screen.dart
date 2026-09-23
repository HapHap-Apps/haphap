import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haphap_fe/core/network/token_manager.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = await Future.wait([
      TokenManager.getToken(),
      TokenManager.getRole(),
      Future<void>.delayed(const Duration(seconds: 1)),
    ]);
    if (!mounted) return;

    final token = session[0] as String?;
    final role = session[1] as String?;
    if (token == null || token.isEmpty || role == null || role.isEmpty) {
      context.go(AppRoutes.onboarding);
      return;
    }

    if (role == 'ADMIN') {
      context.go(AppRoutes.adminBeranda);
    } else if (role == 'MERCHANT') {
      context.go(AppRoutes.merchantBeranda);
    } else {
      context.go(AppRoutes.beranda);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SvgPicture.asset(
          'assets/images/logo-haphap.svg',
          width: AppSizes.logoWidth,
        ),
      ),
    );
  }
}
