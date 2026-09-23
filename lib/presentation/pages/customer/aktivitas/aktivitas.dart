import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/navigations/tab_bar.dart';
import 'package:haphap_fe/presentation/widgets/cards/aktivitas_proses.dart';
import 'package:haphap_fe/presentation/widgets/cards/aktivitas_lainnya.dart';
import 'package:haphap_fe/presentation/widgets/cards/aktivitas_riwayat.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';

class _OrderItem {
  final String orderId;
  final String status;
  final int totalAmount;
  final String merchantName;
  final String merchantId;
  final String? merchantAvatar;
  final String createdAt;
  final String? qrCode;
  final bool hasReview;

  const _OrderItem({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    required this.merchantName,
    required this.merchantId,
    this.merchantAvatar,
    required this.createdAt,
    this.qrCode,
    this.hasReview = false,
  });

  bool get hasQrCode => qrCode != null && qrCode!.isNotEmpty;

  factory _OrderItem.fromJson(Map<String, dynamic> json) {
    final merchant = json['merchant'] as Map<String, dynamic>? ?? {};
    return _OrderItem(
      orderId: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      totalAmount: json['totalAmount'] as int? ?? 0,
      merchantName: merchant['merchantName'] as String? ?? '-',
      merchantId: merchant['id'] as String? ?? '',
      merchantAvatar: merchant['avatar'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      qrCode: json['qrCode'] as String?,
      hasReview: json['review'] != null,
    );
  }
}

class AktivitasPage extends StatefulWidget {
  final int initialTab;
  const AktivitasPage({super.key, this.initialTab = 0});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage>
    with WidgetsBindingObserver {
  late int _currentTabIndex;

  List<_OrderItem> _orders = [];
  bool _isLoading = true;
  String? _error;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTab;
    WidgetsBinding.instance.addObserver(this);
    _fetchOrders();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchOrders(silent: true);
    });
  }

  @override
  void didUpdateWidget(covariant AktivitasPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _currentTabIndex = widget.initialTab;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchOrders(silent: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);

    try {
      final response = await ApiClient.get('/orders/me');
      final raw = response['data'] ?? response;
      final list = (raw as List).cast<Map<String, dynamic>>();
      if (mounted) {
        setState(() {
          _orders = list.map(_OrderItem.fromJson).toList();
          _isLoading = false;
          _error = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat aktivitas.';
          _isLoading = false;
        });
      }
    }
  }

  List<_OrderItem> get _activeOrders => _orders
      .where(
        (o) =>
            o.status == 'PENDING' ||
            o.status == 'PROCESSING' ||
            o.status == 'READY',
      )
      .toList();

  List<_OrderItem> get _historyOrders => _orders
      .where((o) => o.status == 'CANCELLED' || o.status == 'COMPLETED')
      .toList();

  String _formatPrice(int price) =>
      'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _statusText(_OrderItem order) {
    switch (order.status) {
      case 'PENDING':
        return 'Menunggu Pembayaran';
      case 'PROCESSING':
        return 'Pesanan lagi Dikonfirmasi';
      case 'READY':
        return order.hasQrCode
            ? 'Tunjukkan QR ke Kasir'
            : 'Pesanan Sedang Disiapkan';
      case 'COMPLETED':
        return 'Pesanan Selesai';
      default:
        return order.status;
    }
  }

  String _mainText(_OrderItem order) {
    switch (order.status) {
      case 'PENDING':
        return 'Bayar Sekarang!';
      case 'PROCESSING':
        return 'Menunggu Konfirmasi!';
      case 'READY':
        return order.hasQrCode ? 'Tunjukkan QRmu!' : 'Sedang disiapkan!';
      case 'COMPLETED':
        return 'Selamat Menikmati!';
      default:
        return '-';
    }
  }

  String _imagePath(_OrderItem order) {
    switch (order.status) {
      case 'PENDING':
        return 'assets/images/aktivitas_puy_waiting1.png';
      case 'PROCESSING':
        return 'assets/images/aktivitas_puy_processing.png';
      case 'READY':
        return order.hasQrCode
            ? 'assets/images/aktivitas_puy_done.png'
            : 'assets/images/aktivitas_puy_processing.png';
      case 'COMPLETED':
        return 'assets/images/aktivitas_puy_done.png';
      default:
        return 'assets/images/aktivitas_puy_processing.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            _buildHeader(context),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: HapHapTabBar(
                currentIndex: _currentTabIndex,
                onTap: (index) => setState(() => _currentTabIndex = index),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        children: [
          const Expanded(
            child: HapHapPageHeader(
              title: 'Aktivitas',
              showBackButton: false,
              fontSize: AppTypography.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildProsesTab();
      case 1:
        return _buildRiwayatTab();
      case 2:
        return _buildLainnyaTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildProsesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const AppTextStyle(
            color: AppColors.error,
            fontSize: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    if (_activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/puypuy_laper_nih.png',
              width: AppSizes.illustrationWidth,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(height: AppSpacing.bottomClearance),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Puypuy laper nih... 🥺',
              style: AppTextStyle(
                fontSize: AppTypography.titleMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchOrders(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          children: [
            ..._activeOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: GestureDetector(
                  onTap: () {
                    if (order.status == 'PENDING') {
                      context.push(AppRoutes.checkout, extra: order.orderId);
                    } else if (order.status == 'PROCESSING' ||
                        order.status == 'READY') {
                      context.push(
                        AppRoutes.detailPesanan,
                        extra: order.orderId,
                      );
                    }
                  },
                  child: HapHapAktivitasCard(
                    statusText: _statusText(order),
                    mainText: _mainText(order),
                    restaurantName: order.merchantName,
                    imagePath: _imagePath(order),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.bottomClearance),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_historyOrders.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat pesanan.',
          style: AppTextStyle(
            color: AppColors.greyDark,
            fontSize: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchOrders(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        itemCount: _historyOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (_, i) {
          final order = _historyOrders[i];
          final showRatingButton =
              order.status == 'COMPLETED' && !order.hasReview;
          final buttonText = showRatingButton
              ? 'Beri Rating'
              : (order.status == 'CANCELLED' ? 'Pesan Lagi' : null);

          return GestureDetector(
            onTap: () =>
                context.push(AppRoutes.detailPesanan, extra: order.orderId),
            child: HapHapRiwayatCard(
              imageUrl: order.merchantAvatar ?? '',
              dateStatusText:
                  '${order.createdAt.substring(0, 10)} · ${order.status == 'COMPLETED' ? 'Selesai' : 'Dibatalkan'}',
              restaurantName: order.merchantName,
              price: _formatPrice(order.totalAmount),
              buttonText: buttonText,
              onButtonPressed: buttonText != null
                  ? () {
                      if (showRatingButton) {
                        context.push(
                          AppRoutes.beriRating,
                          extra: {
                            'orderId': order.orderId,
                            'merchantId': order.merchantId,
                            'merchantName': order.merchantName,
                            'merchantAvatar': order.merchantAvatar ?? '',
                          },
                        );
                      } else {
                        // TODO: implement reorder
                      }
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLainnyaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        children: const [
          HapHapAktivitasLainnyaCard(
            title: 'HapHap lagi ada promo\nspesial nih 😋',
            subtitle: 'Ayo buruan pesan sebelum kehabisan!',
            imagePath: 'assets/images/logo_haphap.png',
          ),
          SizedBox(height: AppSpacing.bottomClearance),
        ],
      ),
    );
  }
}
