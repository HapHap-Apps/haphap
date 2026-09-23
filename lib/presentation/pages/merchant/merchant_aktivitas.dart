import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/navigations/tab_bar.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';
import 'package:haphap_fe/presentation/widgets/cards/merchant_order.dart';
import 'package:haphap_fe/data/services/order_service.dart';
import 'package:haphap_fe/data/models/order_model.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';

class AktivitasMerchantPage extends StatefulWidget {
  const AktivitasMerchantPage({super.key});

  @override
  State<AktivitasMerchantPage> createState() => _AktivitasMerchantPageState();
}

class _AktivitasMerchantPageState extends State<AktivitasMerchantPage> {
  int _currentTabIndex = 0;
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUnauthorized = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _isUnauthorized = false;
      });
    }

    try {
      final orders = await OrderService.fetchOrderMerchant();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
        _errorMessage = null;
        _isUnauthorized = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (e.statusCode == 401) {
          _isUnauthorized = true;
          _errorMessage = 'Sesi kamu telah berakhir. Silakan login kembali.';
        } else if (e.statusCode == 403) {
          _errorMessage = 'Kamu tidak memiliki akses ke halaman ini.';
        } else {
          _errorMessage = e.message;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Tidak dapat memuat data pesanan. Periksa koneksi internet kamu.';
      });
    }
  }

  Future<void> _onRefresh() async {
    try {
      final orders = await OrderService.fetchOrderMerchant();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _errorMessage = null;
        _isUnauthorized = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
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
        _errorMessage =
            'Tidak dapat memuat data pesanan. Periksa koneksi internet kamu.';
      });
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: HapHapTabBar(
                  currentIndex: _currentTabIndex,
                  tabs: const [
                    'Baru',
                    'Sedang Disiapkan',
                    'Siap Diambil',
                    'Selesai',
                  ],
                  onTap: (index) {
                    setState(() {
                      _currentTabIndex = index;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    List<OrderModel> filteredOrders;
    MerchantOrderStatus currentStatus;

    switch (_currentTabIndex) {
      case 0:
        filteredOrders = _orders
            .where((o) => o.status == 'PROCESSING')
            .toList();
        currentStatus = MerchantOrderStatus.baru;
        break;
      case 1:
        filteredOrders = _orders
            .where(
              (o) =>
                  o.status == 'READY' &&
                  (o.qrCode == null || o.qrCode!.isEmpty),
            )
            .toList();
        currentStatus = MerchantOrderStatus.sedangDisiapkan;
        break;
      case 2:
        filteredOrders = _orders
            .where(
              (o) =>
                  o.status == 'READY' &&
                  o.qrCode != null &&
                  o.qrCode!.isNotEmpty,
            )
            .toList();
        currentStatus = MerchantOrderStatus.siapDiambil;
        break;
      case 3:
      default:
        filteredOrders = _orders
            .where((o) => o.status == 'COMPLETED' || o.status == 'CANCELLED')
            .toList();
        currentStatus = MerchantOrderStatus.selesai;
        break;
    }

    return _buildListPesanan(filteredOrders, currentStatus);
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
            SizedBox(
              width: AppSizes.narrowPanel,
              child: HapHapButton(
                text: _isUnauthorized ? 'Login Ulang' : 'Coba Lagi',
                onPressed: () {
                  if (_isUnauthorized) {
                    context.go(AppRoutes.login);
                  } else {
                    _fetchOrders();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListPesanan(
    List<OrderModel> pesananList,
    MerchantOrderStatus status,
  ) {
    if (pesananList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: AppSizes.touchTarget,
              color: AppColors.greyDark,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Belum ada pesanan.',
              style: AppTextStyle(
                color: AppColors.greyDark,
                fontSize: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.sm,
        ),
        itemCount: pesananList.length,
        itemBuilder: (context, index) {
          final order = pesananList[index];

          final MerchantOrderStatus cardStatus;
          if (order.status == 'READY') {
            cardStatus = (order.qrCode != null && order.qrCode!.isNotEmpty)
                ? MerchantOrderStatus.siapDiambil
                : MerchantOrderStatus.sedangDisiapkan;
          } else if (order.status == 'CANCELLED') {
            cardStatus = MerchantOrderStatus.dibatalkan;
          } else {
            cardStatus = status;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: HapHapMerchantOrderCard(
              status: cardStatus,
              customerName: order.customerName ?? 'Customer',
              orderId: order.orderId,
              items: order.orderItems,
              totalPrice: 'Rp ${_formatPrice(order.totalAmount)}',
              onAccept: cardStatus == MerchantOrderStatus.baru
                  ? () async {
                      try {
                        await OrderService.acceptOrder(order.orderId);
                        if (!context.mounted) return;
                        _fetchOrders();
                      } catch (_) {
                        if (!context.mounted) return;
                        AppSnackbar.showError(
                          context,
                          'Gagal menerima pesanan. Coba lagi.',
                        );
                      }
                    }
                  : null,
              onReject: cardStatus == MerchantOrderStatus.baru
                  ? () async {
                      try {
                        await OrderService.rejectOrder(order.orderId);
                        if (!context.mounted) return;
                        _fetchOrders();
                      } catch (_) {
                        if (!context.mounted) return;
                        AppSnackbar.showError(
                          context,
                          'Gagal menolak pesanan. Coba lagi.',
                        );
                      }
                    }
                  : null,
              onReady: cardStatus == MerchantOrderStatus.sedangDisiapkan
                  ? () async {
                      try {
                        await OrderService.readyOrder(order.orderId);
                        if (!context.mounted) return;
                        _fetchOrders();
                      } catch (_) {
                        if (!context.mounted) return;
                        AppSnackbar.showError(
                          context,
                          'Gagal menandai siap ambil. Coba lagi.',
                        );
                      }
                    }
                  : null,
              onScanQR: cardStatus == MerchantOrderStatus.siapDiambil
                  ? () {
                      context.push(AppRoutes.merchantScanQR).then((_) {
                        _fetchOrders();
                      });
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
