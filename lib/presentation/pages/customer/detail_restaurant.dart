import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/data/models/merchant_model.dart';
import 'package:haphap_fe/data/services/merchant_service.dart';
import 'package:haphap_fe/presentation/widgets/cards/menu_card.dart';
import 'package:haphap_fe/presentation/widgets/cards/restaurant_card.dart';
import 'package:haphap_fe/presentation/pages/customer/checkout.dart';

class DetailRestoranPage extends StatefulWidget {
  final String merchantId;

  const DetailRestoranPage({super.key, required this.merchantId});

  @override
  State<DetailRestoranPage> createState() => _DetailRestoranPageState();
}

class _DetailRestoranPageState extends State<DetailRestoranPage> {
  MerchantDetailModel? _merchant;
  bool _isLoading = true;
  String? _error;

  final Map<String, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _fetchMerchant();
  }

  Future<void> _fetchMerchant() async {
    try {
      final merchant = await MerchantService.fetchOne(widget.merchantId);
      if (!mounted) return;
      setState(() {
        _merchant = merchant;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat detail merchant.';
        _isLoading = false;
      });
    }
  }

  int get _cartTotalItems => _cart.values.fold(0, (sum, qty) => sum + qty);

  List<SurplusItemModel> get _activeSurplusItems =>
      _merchant?.surplusItems
          .where((item) => item.isActive && item.stock > 0)
          .toList() ??
      [];

  int get _cartTotalPrice {
    if (_merchant == null) return 0;
    return _cart.entries.fold(0, (sum, entry) {
      final item = _merchant!.surplusItems.firstWhere(
        (i) => i.surplusItemId == entry.key,
        orElse: () => const SurplusItemModel(
          surplusItemId: '',
          name: '',
          discountPrice: 0,
          originalPrice: 0,
          stock: 0,
        ),
      );
      return sum + (item.discountPrice * entry.value);
    });
  }

  void _addToCart(SurplusItemModel item) {
    final current = _cart[item.surplusItemId] ?? 0;
    if (current < item.stock) {
      setState(() => _cart[item.surplusItemId] = current + 1);
    }
  }

  void _removeFromCart(SurplusItemModel item) {
    final current = _cart[item.surplusItemId] ?? 0;
    if (current > 0) {
      setState(() {
        if (current == 1) {
          _cart.remove(item.surplusItemId);
        } else {
          _cart[item.surplusItemId] = current - 1;
        }
      });
    }
  }

  bool _isValidUrl(String? url) =>
      url != null && (url.startsWith('http://') || url.startsWith('https://'));

  void _goToCheckout() {
    if (_merchant == null) return;

    context.push(
      AppRoutes.checkout,
      extra: CheckoutArgs(
        merchantId: widget.merchantId,
        merchantName: _merchant!.merchantName,
        cart: Map<String, int>.from(_cart),
        items: _activeSurplusItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: AppElevations.none,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _cartTotalItems > 0
          ? _buildFloatingCart()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            _error!,
            style: const AppTextStyle(
              color: AppColors.error,
              fontSize: AppTypography.bodyMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final merchant = _merchant!;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(merchant),
          const SizedBox(height: AppSpacing.xxl),
          _buildDaftarMenuSection(merchant),
          const SizedBox(height: AppSpacing.largeSection),
        ],
      ),
    );
  }

  Widget _buildHeroSection(MerchantDetailModel merchant) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heroHeight = AppLayout.responsiveExtent(
          constraints.maxWidth,
          fraction: AppLayout.heroHeightFraction,
          min: AppSizes.heroMinHeight,
          max: AppSizes.heroHeight,
        );
        final cardTop = heroHeight - AppSpacing.loose;

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              width: double.infinity,
              height: heroHeight,
              child: _isValidUrl(merchant.avatar)
                  ? Image.network(
                      merchant.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.primary),
                    )
                  : Container(color: AppColors.primary),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: cardTop,
                left: AppLayout.pagePadding(context),
                right: AppLayout.pagePadding(context),
              ),
              child: HapHapRestaurantCard(
                imageUrl: merchant.avatar ?? '',
                distanceTime: merchant.address ?? '',
                restaurantName: merchant.merchantName,
                ratingText: merchant.rating != null
                    ? '${merchant.rating!.toStringAsFixed(1)} rating'
                    : 'Belum ada rating',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDaftarMenuSection(MerchantDetailModel merchant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.pagePadding(context),
          ),
          child: Text(
            'Menu ${merchant.merchantName}',
            style: const AppTextStyle(
              fontSize: AppTypography.bodyLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_activeSurplusItems.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppLayout.pagePadding(context),
            ),
            child: Text(
              'Belum ada surplus item tersedia.',
              style: AppTextStyle(
                color: AppColors.greyDark,
                fontSize: AppTypography.bodyMedium,
              ),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppLayout.pagePadding(context),
            ),
            child: Column(
              children: _activeSurplusItems.map((item) {
                final cartCount = _cart[item.surplusItemId] ?? 0;
                return Column(
                  children: [
                    HapHapMenuCard(
                      imageUrl: item.image ?? '',
                      title: item.name,
                      description: item.description ?? '',
                      price: 'Rp ${item.discountPrice}',
                      stockCount: item.stock,
                      cartCount: cartCount,
                      onAdd: () => _addToCart(item),
                      onRemove: () => _removeFromCart(item),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingCart() {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: AppSizes.bottomActionHeight + bottomSafeArea,
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: bottomSafeArea,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.largeTop,
        boxShadow: AppShadows.surfaceTop,
      ),
      child: Center(
        child: InkWell(
          onTap: _goToCheckout,
          borderRadius: AppRadii.xxl,
          child: Container(
            height: AppSizes.touchTarget,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadii.xxl,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Keranjang - $_cartTotalItems Hidangan',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const AppTextStyle(
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Text(
                    'Rp $_cartTotalPrice',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const AppTextStyle(
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
