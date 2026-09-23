import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/core/constants/app_icons.dart';
import 'package:haphap_fe/data/models/merchant_model.dart';
import 'package:haphap_fe/data/services/order_service.dart';
import 'package:haphap_fe/data/services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';

class CheckoutArgs {
  final String merchantId;
  final String merchantName;
  final Map<String, int> cart;
  final List<SurplusItemModel> items;

  const CheckoutArgs({
    required this.merchantId,
    required this.merchantName,
    required this.cart,
    required this.items,
  });
}

class CheckoutPage extends StatefulWidget {
  final CheckoutArgs? args;
  final String? pendingOrderId;

  const CheckoutPage({super.key, this.args, this.pendingOrderId})
    : assert(args != null || pendingOrderId != null);

  bool get isPendingMode => pendingOrderId != null;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPaymentMethod = 'QRIS';
  bool _isSubmitting = false;
  bool _isCheckingPayment = false;
  String? _errorMessage;
  String? _pendingOrderId;

  late Map<String, int> _cart;

  bool _isLoadingOrder = false;
  String _merchantName = '';
  String _merchantId = '';
  List<SurplusItemModel> _loadedItems = [];
  int? _fetchedTotalAmount;

  @override
  void initState() {
    super.initState();
    if (widget.isPendingMode) {
      _cart = {};
      _pendingOrderId = widget.pendingOrderId;
      _fetchPendingOrder();
    } else {
      _cart = Map<String, int>.from(widget.args!.cart);
      _merchantName = widget.args!.merchantName;
      _merchantId = widget.args!.merchantId;
      _loadedItems = widget.args!.items;
    }
  }

  Future<void> _fetchPendingOrder() async {
    setState(() => _isLoadingOrder = true);
    try {
      final order = await OrderService.fetchOrder(widget.pendingOrderId!);
      if (!mounted) return;

      final items = <SurplusItemModel>[];
      final cart = <String, int>{};
      for (final oi in order.orderItems) {
        items.add(
          SurplusItemModel(
            surplusItemId: oi.surplusItemId,
            name: oi.name,
            discountPrice: oi.discountPrice,
            originalPrice: oi.originalPrice,
            stock: oi.quantity,
          ),
        );
        cart[oi.surplusItemId] = oi.quantity;
      }

      setState(() {
        _loadedItems = items;
        _cart = cart;
        _merchantName = order.merchant?.merchantName ?? 'Merchant';
        _merchantId = order.merchantId;
        _fetchedTotalAmount = order.totalAmount;
        _isLoadingOrder = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat pesanan. Silakan coba lagi.';
        _isLoadingOrder = false;
      });
    }
  }

  List<SurplusItemModel> get _activeItems => _loadedItems
      .where((item) => (_cart[item.surplusItemId] ?? 0) > 0)
      .toList();

  int get _totalPrice {
    if (_fetchedTotalAmount != null) return _fetchedTotalAmount!;
    return _loadedItems.fold(0, (sum, item) {
      final qty = _cart[item.surplusItemId] ?? 0;
      return sum + (item.discountPrice * qty);
    });
  }

  void _add(SurplusItemModel item) {
    final current = _cart[item.surplusItemId] ?? 0;
    if (current < item.stock) {
      setState(() => _cart[item.surplusItemId] = current + 1);
    }
  }

  void _remove(SurplusItemModel item) {
    final current = _cart[item.surplusItemId] ?? 0;
    if (current > 1) {
      setState(() => _cart[item.surplusItemId] = current - 1);
    } else if (current == 1) {
      setState(() => _cart.remove(item.surplusItemId));
    }
  }

  bool _isValidUrl(String? url) =>
      url != null && (url.startsWith('http://') || url.startsWith('https://'));

  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );

  Future<void> _buatPesanan() async {
    if (_activeItems.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final orderItems = _cart.entries
          .map((e) => {'surplusItemId': e.key, 'quantity': e.value})
          .toList();

      final order = await OrderService.createOrder(
        merchantId: _merchantId,
        orderItems: orderItems,
      );

      if (!mounted) return;

      if (_selectedPaymentMethod == 'Cash') {
        context.go(AppRoutes.aktivitas);
        return;
      }

      final payment = await PaymentService.createPayment(
        order['orderId'] as String,
      );

      if (!mounted) return;

      final uri = Uri.parse(payment.redirectUrl);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          setState(() => _pendingOrderId = order['orderId'] as String);
        }
      } catch (e) {
        if (mounted) {
          setState(
            () => _errorMessage = 'Tidak dapat membuka halaman pembayaran.',
          );
        }
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _checkPaymentStatus() async {
    if (_pendingOrderId == null || _isCheckingPayment) return;

    setState(() {
      _isCheckingPayment = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.get('/orders/$_pendingOrderId');
      final data = response['data'] ?? response;
      final status = (data['status'] as String?)?.toUpperCase() ?? '';

      if (!mounted) return;

      if (status == 'PROCESSING') {
        context.go(AppRoutes.aktivitas);
      } else if (status == 'CANCELLED' || status == 'EXPIRED') {
        setState(() {
          _errorMessage = 'Pesanan dibatalkan atau kadaluarsa.';
          _pendingOrderId = null;
        });
      } else {
        setState(
          () => _errorMessage =
              'Pembayaran belum terkonfirmasi. Pastikan kamu telah menyelesaikan pembayaran.',
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Gagal mengecek status. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _isCheckingPayment = false);
    }
  }

  Future<void> _bayarUlang() async {
    if (_pendingOrderId == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final payment = await PaymentService.createPayment(_pendingOrderId!);

      if (!mounted) return;

      final uri = Uri.parse(payment.redirectUrl);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          setState(
            () => _errorMessage = 'Tidak dapat membuka halaman pembayaran.',
          );
        }
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingOrder) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: HapHapPageHeader(title: _merchantName),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rangkuman Pesanan',
                      style: AppTextStyle(
                        fontSize: AppTypography.titleLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    if (_pendingOrderId == null)
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          'Tambah Pesanan',
                          style: AppTextStyle(
                            fontSize: AppTypography.labelMedium,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: AppRadii.md,
                      border: Border.all(color: AppColors.errorBorder),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyle(
                        color: AppColors.errorDark,
                        fontSize: AppTypography.labelMedium,
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadii.lg,
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_activeItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'Keranjang kosong.',
                            style: AppTextStyle(
                              color: AppColors.greyDark,
                              fontSize: AppTypography.bodyMedium,
                            ),
                          ),
                        )
                      else
                        ..._activeItems.map(
                          (item) => Column(
                            children: [
                              _buildCartItem(item),
                              const Divider(
                                color: AppColors.surfaceBorder,
                                height: AppSizes.hairline,
                                thickness: 1,
                              ),
                            ],
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rincian Pembayaran',
                              style: AppTextStyle(
                                fontSize: AppTypography.bodyMedium,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: AppTextStyle(
                                    fontSize: AppTypography.bodyMedium,
                                    color: AppColors.greyDark,
                                  ),
                                ),
                                Text(
                                  'Rp ${_formatPrice(_totalPrice)}',
                                  style: const AppTextStyle(
                                    fontSize: AppTypography.bodyMedium,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.dialogClearance),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCheckoutBottomBar(),
    );
  }

  Widget _buildCartItem(SurplusItemModel item) {
    final qty = _cart[item.surplusItemId] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: AppRadii.md,
            child: _isValidUrl(item.image)
                ? Image.network(
                    item.image!,
                    width: AppSizes.avatarMedium,
                    height: AppSizes.avatarMedium,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderBox(),
                  )
                : _placeholderBox(),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: SizedBox(
              height: AppSizes.avatarMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const AppTextStyle(
                          fontSize: AppTypography.bodyMedium,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          item.description!,
                          style: const AppTextStyle(
                            fontSize: AppTypography.labelMedium,
                            color: AppColors.greyDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${_formatPrice(item.discountPrice)}',
                        style: const AppTextStyle(
                          fontSize: AppTypography.bodyMedium,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (_pendingOrderId != null)
                        Text(
                          'x$qty',
                          style: const AppTextStyle(
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _remove(item),
                              behavior: HitTestBehavior.opaque,
                              child: const Icon(
                                Icons.remove_circle,
                                color: AppColors.primary,
                                size: AppSizes.iconMd,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                '$qty',
                                style: const AppTextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _add(item),
                              behavior: HitTestBehavior.opaque,
                              child: const Icon(
                                Icons.add_circle,
                                color: AppColors.primary,
                                size: AppSizes.iconMd,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBox() => Container(
    width: AppSizes.avatarMedium,
    height: AppSizes.avatarMedium,
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.15),
      borderRadius: AppRadii.md,
    ),
  );

  Widget _buildCheckoutBottomBar() {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xl,
        bottom: bottomSafeArea > AppSpacing.none
            ? bottomSafeArea
            : AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.largeTop,
        boxShadow: AppShadows.surfaceTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  _selectedPaymentMethod == 'QRIS'
                      ? SvgPicture.asset(AppIcons.qris, height: AppSizes.iconMd)
                      : const Icon(
                          Icons.payments,
                          color: AppColors.success,
                          size: AppSizes.iconMd,
                        ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    _selectedPaymentMethod,
                    style: const AppTextStyle(
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _isSubmitting ? null : _showPaymentMethodDialog,
                child: const Text(
                  'Ubah',
                  style: AppTextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          if (_pendingOrderId != null) ...[
            HapHapButton(
              text: 'Saya Sudah Bayar',
              isExpanded: true,
              isLoading: _isCheckingPayment,
              onPressed: _checkPaymentStatus,
            ),
            const SizedBox(height: AppSpacing.md),
            HapHapButton(
              text: 'Bayar Ulang',
              isExpanded: true,
              isOutline: true,
              onPressed: (_isCheckingPayment || _isSubmitting)
                  ? null
                  : _bayarUlang,
            ),
          ] else
            HapHapButton(
              text: 'Buat Pesanan',
              isExpanded: true,
              isLoading: _isSubmitting,
              onPressed: _activeItems.isEmpty ? null : _buatPesanan,
            ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(
            top: AppSpacing.xxl,
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: AppSpacing.xxxl,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadii.largeTop,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Metode Pembayaran',
                style: AppTextStyle(
                  fontSize: AppTypography.titleLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildPaymentOption(
                title: 'Cash',
                icon: const Icon(
                  Icons.payments,
                  color: AppColors.success,
                  size: AppSizes.iconMd,
                ),
                value: 'Cash',
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildPaymentOption(
                title: 'QRIS',
                icon: SvgPicture.asset(AppIcons.qris, height: AppSizes.iconMd),
                value: 'QRIS',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required Widget icon,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = value);
        Navigator.pop(context);
      },
      child: Container(
        color: AppColors.transparent,
        child: Row(
          children: [
            icon,
            const SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: const AppTextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const Spacer(),
            Container(
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.greyLight,
                  width: isSelected ? 6 : 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
