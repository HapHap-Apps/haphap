import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:haphap_fe/presentation/pages/customer/akun/edit_profil.dart';
import 'package:haphap_fe/presentation/pages/customer/akun/statistik.dart';
import 'package:haphap_fe/presentation/shell/merchant_shell.dart';
import 'package:haphap_fe/presentation/shell/user_shell.dart';
import 'package:haphap_fe/presentation/shell/admin_shell.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';

import 'package:haphap_fe/presentation/pages/splash/splash_screen.dart';
import 'package:haphap_fe/presentation/pages/splash/onboarding_screen.dart';
import 'package:haphap_fe/presentation/pages/auth/login_screen.dart';
import 'package:haphap_fe/presentation/pages/auth/register_screen.dart';

import 'package:haphap_fe/presentation/pages/customer/beranda.dart';
import 'package:haphap_fe/presentation/pages/customer/jelajah.dart';
import 'package:haphap_fe/presentation/pages/customer/aktivitas/aktivitas.dart';
import 'package:haphap_fe/presentation/pages/customer/aktivitas/detail_pesanan.dart';
import 'package:haphap_fe/presentation/pages/customer/aktivitas/beri_rating.dart';

import 'package:haphap_fe/presentation/pages/customer/akun/akun.dart';

import 'package:haphap_fe/presentation/pages/customer/detail_restaurant.dart';
import 'package:haphap_fe/presentation/pages/customer/checkout.dart';

import 'package:haphap_fe/presentation/pages/merchant/merchant_beranda.dart';
import 'package:haphap_fe/presentation/pages/merchant/merchant_menu.dart';
import 'package:haphap_fe/presentation/pages/merchant/merchant_aktivitas.dart';
import 'package:haphap_fe/presentation/pages/merchant/merchant_akun.dart';
import 'package:haphap_fe/presentation/pages/merchant/merchant_statistik.dart';
import 'package:haphap_fe/presentation/pages/merchant/merchant_scan_qr.dart';
import 'package:haphap_fe/presentation/pages/merchant/registration/merchant_registration_page.dart';
import 'package:haphap_fe/presentation/pages/merchant/merchant_edit_profil.dart';

import 'package:haphap_fe/presentation/pages/admin/admin_beranda.dart';
import 'package:haphap_fe/presentation/pages/admin/admin_pengajuan.dart';
import 'package:haphap_fe/presentation/pages/admin/admin_detail_pengajuan.dart';
import 'package:haphap_fe/presentation/pages/admin/admin_akun.dart';
import 'package:haphap_fe/data/models/application_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  static const String beranda = '/beranda';
  static const String jelajah = '/jelajah';
  static const String aktivitas = '/aktivitas';
  static const String akun = '/akun';
  static const String detailPesanan = '/detail';
  static const String beriRating = '/beri-rating';

  static const String editProfil = '/edit-profil';
  static const String statistik = '/statistik';


  static const String detailRestoran = '/detail-restoran';
  static const String checkout = '/checkout';

  static const String merchantBeranda = '/merchant/beranda';
  static const String merchantMenu = '/merchant/menu';
  static const String merchantAktivitas = '/merchant/aktivitas';
  static const String merchantAkun = '/merchant/akun';
  static const String merchantStatistik = '/merchant/statistik';
  static const String merchantEditProfil = '/merchant/edit-profil';

  static const String adminBeranda = '/admin/beranda';
  static const String adminPengajuan = '/admin/pengajuan';
  static const String adminAkun = '/admin/akun';
  static const String adminDetailPengajuan = '/admin/detail-pengajuan';
  static const String merchantScanQR = '/merchant/scan-qr';
  static const String merchantRegister = '/merchant/register';
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: HapHapButton(
        text: 'Kembali ke Beranda',
        isText: true,
        onPressed: () => context.go(AppRoutes.splash),
      ),
    ),
  ),
  routes: [
    GoRoute(path: '/', redirect: (context, state) => AppRoutes.beranda),
    GoRoute(
      path: '/payment/finish',
      redirect: (context, state) => AppRoutes.aktivitas,
    ),
    GoRoute(
      path: '/aktivitas-redirect',
      redirect: (context, state) => AppRoutes.aktivitas,
    ),
    GoRoute(
      path: AppRoutes.merchantScanQR,
      builder: (_, __) => const MerchantScanQRPage(),
    ),
    GoRoute(
      path: AppRoutes.merchantRegister,
      builder: (_, __) => const MerchantRegistrationPage(),
    ),
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.detailPesanan,
      builder: (context, state) {
        final orderId = state.extra as String?;
        return DetailPesananPage(orderId: orderId);
      },
    ),
    GoRoute(
      path: AppRoutes.beriRating,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return BeriRatingPage(
          orderId: extra['orderId'] as String,
          merchantId: extra['merchantId'] as String,
          merchantName: extra['merchantName'] as String,
          merchantAvatar: extra['merchantAvatar'] as String,
        );
      },
    ),

    GoRoute(
      path: '${AppRoutes.detailRestoran}/:merchantId',
      builder: (context, state) {
        final merchantId = state.pathParameters['merchantId']!;
        return DetailRestoranPage(merchantId: merchantId);
      },
    ),
    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is CheckoutArgs) {
          return CheckoutPage(args: extra);
        } else if (extra is String) {
          return CheckoutPage(pendingOrderId: extra);
        }
        return const Scaffold(
          body: Center(child: Text('Invalid checkout arguments')),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.editProfil,
      builder: (context, state) => const EditProfilPage(),
    ),
    GoRoute(
      path: AppRoutes.statistik,
      builder: (context, state) => const StatistikPage(),
    ),

    GoRoute(
      path: AppRoutes.merchantStatistik,
      builder: (context, state) => const StatistikMerchantPage(),
    ),
    GoRoute(
      path: AppRoutes.merchantEditProfil,
      builder: (context, state) => const EditProfilMerchantPage(),
    ),
    GoRoute(
      path: '/finish',
      redirect: (context, state) {
        final orderId = state.uri.queryParameters['order_id'];
        final status = state.uri.queryParameters['transaction_status'];
        debugPrint('Midtrans Redirect - Order: $orderId, Status: $status');
        return AppRoutes.aktivitas;
      },
    ),
    GoRoute(
      path: '/payment/finish',
      redirect: (context, state) => AppRoutes.aktivitas,
    ),

    GoRoute(
      path: AppRoutes.adminDetailPengajuan,
      builder: (context, state) {
        final app = state.extra as ApplicationModel;
        return DetailPengajuanAdminPage(application: app);
      },
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.beranda,
              builder: (context, state) => const BerandaPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.jelajah,
              builder: (context, state) {
                final category = state.uri.queryParameters['category'];
                return JelajahPage(initialCategory: category);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.aktivitas,
              builder: (context, state) {
                final tabStr = state.uri.queryParameters['tab'];
                final initialTab = tabStr != null
                    ? int.tryParse(tabStr) ?? 0
                    : 0;
                return AktivitasPage(initialTab: initialTab);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.akun,
              builder: (context, state) => const AkunPage(),
            ),
          ],
        ),
      ],
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MerchantShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.merchantBeranda,
              builder: (context, state) => const BerandaMerchantPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.merchantMenu,
              builder: (context, state) => const MenuMerchantPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.merchantAktivitas,
              builder: (context, state) => const AktivitasMerchantPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.merchantAkun,
              builder: (context, state) => const AkunMerchantPage(),
            ),
          ],
        ),
      ],
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdminShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminBeranda,
              builder: (context, state) => const BerandaAdminPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminPengajuan,
              builder: (context, state) => const PengajuanAdminPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminAkun,
              builder: (context, state) => const AkunAdminPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
