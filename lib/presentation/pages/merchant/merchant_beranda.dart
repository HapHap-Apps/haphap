import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/constants/app_icons.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/buttons/beranda_merchant_category.dart';
import 'package:haphap_fe/presentation/widgets/cards/merchant_add_stock.dart';
import 'package:haphap_fe/presentation/widgets/cards/merchant_menu.dart';
import 'package:haphap_fe/presentation/widgets/cards/beranda_stats.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';
import 'package:haphap_fe/data/services/surplus_service.dart';
import 'package:haphap_fe/data/models/merchant_model.dart';
import 'package:haphap_fe/core/network/api_client.dart';

class _BerandaMerchantLayout {
  static const double heroTopPadding = AppSpacing.huge;
  static const double heroHorizontalPadding = AppSpacing.xxl;
  static const double heroTaglineToCards = AppSpacing.xxxl;
  static const double heroRedBgBottomCut = AppSpacing.screenBottom;

  static const double statCardSpacing = AppSpacing.lg;

  static const double sectionHorizontalPadding = AppSpacing.xxl;
  static const double sectionTitleToContent = AppSpacing.lg;
  static const double fiturToMenuAktif = AppSpacing.xxxl;
  static const double menuAktifSpacing = AppSpacing.lg;
  static const double categoryItemSpacing = AppSpacing.xl;

  static const double bottomScrollPadding = AppSpacing.screenBottom;
}

class _BerandaMerchantContent {
  static const String statsIncomeTitle = 'Total Penghasilan';
  static const String statsIncomePrefix = 'Rp ';
  static const String statsIncomeSubtitle = 'Total pendapatan kamu';

  static const String statsSavedTitle = 'Berhasil Selamatin';
  static const String statsSavedSubtitle = 'Total porsi diselamatkan';
}

class BerandaMerchantPage extends StatefulWidget {
  const BerandaMerchantPage({super.key});

  @override
  State<BerandaMerchantPage> createState() => _BerandaMerchantPageState();
}

class _BerandaMerchantPageState extends State<BerandaMerchantPage> {
  MerchantDetailModel? _merchant;
  List<SurplusItemModel> _surplusItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUnauthorized = false;

  int _totalRevenue = 0;
  int _totalPortion = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _isUnauthorized = false;
      });
    }

    try {
      final rawJson = await ApiClient.get('/merchants/me');
      final merchantData = rawJson['data'] as Map<String, dynamic>? ?? {};

      final merchant = MerchantDetailModel.fromJson(merchantData);
      _totalRevenue = (merchantData['totalRevenue'] as num?)?.toInt() ?? 0;
      _totalPortion = (merchantData['totalPortion'] as num?)?.toInt() ?? 0;

      final surplusItems = await SurplusService.getMySurplus();

      if (!mounted) return;
      setState(() {
        _merchant = merchant;
        _surplusItems = surplusItems;
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
            'Tidak dapat memuat data. Periksa koneksi internet kamu.';
      });
    }
  }

  Future<void> _deactivateSurplus(SurplusItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
        title: const Text('Nonaktifkan Menu'),
        content: Text(
          'Apakah kamu yakin ingin menonaktifkan "${item.name}" dari daftar surplus aktif?',
        ),
        actions: [
          HapHapButton(
            text: 'Batal',
            isText: true,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          HapHapButton(
            text: 'Nonaktifkan',
            isText: true,
            isDanger: true,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await SurplusService.update(item.surplusItemId, {'isActive': false});
      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        '"${item.name}" berhasil dinonaktifkan.',
      );
      _fetchData();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Gagal menonaktifkan menu. Coba lagi.');
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
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
                          _fetchData();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await _fetchData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroSection(
                merchantName: _merchant?.merchantName ?? 'Toko',
                totalRevenue: _formatPrice(_totalRevenue),
                totalPortion: '$_totalPortion Porsi',
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _FiturSection(),
              const SizedBox(height: _BerandaMerchantLayout.fiturToMenuAktif),
              _MenuAktifSection(
                surplusItems: _surplusItems.where((s) => s.isActive).toList(),
                onStockAdded: () => _fetchData(),
                onDeactivate: _deactivateSurplus,
              ),
              const SizedBox(
                height: _BerandaMerchantLayout.bottomScrollPadding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String merchantName;
  final String totalRevenue;
  final String totalPortion;

  const _HeroSection({
    required this.merchantName,
    required this.totalRevenue,
    required this.totalPortion,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: _BerandaMerchantLayout.heroRedBgBottomCut,
          child: const _RedBackground(),
        ),

        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: _BerandaMerchantLayout.heroTopPadding),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _BerandaMerchantLayout.heroHorizontalPadding,
                ),
                child: Text(
                  'Welcome,\n$merchantName!',
                  style: const AppTextStyle(
                    fontSize: AppTypography.headlineSmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    height: AppTypography.lineHeightNormal,
                  ),
                ),
              ),

              const SizedBox(height: _BerandaMerchantLayout.heroTaglineToCards),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _BerandaMerchantLayout.heroHorizontalPadding,
                ),
                child: _StatsRow(
                  totalRevenue: totalRevenue,
                  totalPortion: totalPortion,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RedBackground extends StatelessWidget {
  const _RedBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: AppRadii.heroRadius,
          bottomRight: AppRadii.heroRadius,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String totalRevenue;
  final String totalPortion;

  const _StatsRow({required this.totalRevenue, required this.totalPortion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HapHapStatsCard(
            title: _BerandaMerchantContent.statsIncomeTitle,
            prefixText: _BerandaMerchantContent.statsIncomePrefix,
            mainValue: totalRevenue,
            valueColor: AppColors.success,
            subtitle: _BerandaMerchantContent.statsIncomeSubtitle,
          ),
        ),
        const SizedBox(width: _BerandaMerchantLayout.statCardSpacing),
        Expanded(
          child: HapHapStatsCard(
            title: _BerandaMerchantContent.statsSavedTitle,
            mainValue: totalPortion,
            valueColor: AppColors.primary,
            subtitle: _BerandaMerchantContent.statsSavedSubtitle,
          ),
        ),
      ],
    );
  }
}

class _FiturSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _BerandaMerchantLayout.sectionHorizontalPadding,
          ),
          child: _SectionTitle(text: 'Fitur'),
        ),
        const SizedBox(height: _BerandaMerchantLayout.sectionTitleToContent),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _BerandaMerchantLayout.sectionHorizontalPadding,
          ),
          child: Row(
            children: [
              HapHapCategoryButton(
                iconPath: AppIcons.menu,
                label: 'Menu',
                onTap: () {
                  context.go(AppRoutes.merchantMenu);
                },
              ),
              const SizedBox(width: _BerandaMerchantLayout.categoryItemSpacing),
              HapHapCategoryButton(
                iconPath: AppIcons.statistics,
                label: 'Statistik',
                onTap: () {
                  context.push(AppRoutes.merchantStatistik);
                },
              ),
              const SizedBox(width: _BerandaMerchantLayout.categoryItemSpacing),
              HapHapCategoryButton(
                iconPath: AppIcons.scan,
                label: 'Scan QR',
                onTap: () => context.push(AppRoutes.merchantScanQR),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuAktifSection extends StatelessWidget {
  final List<SurplusItemModel> surplusItems;
  final VoidCallback? onStockAdded;
  final void Function(SurplusItemModel)? onDeactivate;

  const _MenuAktifSection({
    required this.surplusItems,
    this.onStockAdded,
    this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _BerandaMerchantLayout.sectionHorizontalPadding,
          ),
          child: _SectionTitle(text: 'Menu Aktif'),
        ),
        const SizedBox(height: _BerandaMerchantLayout.sectionTitleToContent),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _BerandaMerchantLayout.sectionHorizontalPadding,
          ),
          child: Column(
            children: [
              HapHapMerchantAddStockCard(
                imagePath: 'assets/images/puypuy_laper_nih.png',
                onStockAdded: onStockAdded,
              ),

              const SizedBox(height: _BerandaMerchantLayout.menuAktifSpacing),

              if (surplusItems.isEmpty)
                _buildEmptyState()
              else
                ...surplusItems.map((item) {
                  final isSoldOut = item.stock <= 0;
                  final stockText = isSoldOut ? 'Sold' : '${item.stock} left';

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: _BerandaMerchantLayout.menuAktifSpacing,
                    ),
                    child: HapHapMerchantMenuCard(
                      title: item.name,
                      description: item.description ?? '',
                      price: 'Rp ${_formatPrice(item.discountPrice)}',
                      stockText: stockText,
                      isSoldOut: isSoldOut,
                      imageUrl: (item.image != null && item.image!.isNotEmpty)
                          ? item.image!
                          : '',
                      onDeactivate: onDeactivate != null
                          ? () => onDeactivate!(item)
                          : null,
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: const [
          Icon(
            Icons.restaurant_menu_outlined,
            size: AppSizes.touchTarget,
            color: AppColors.greyDark,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada menu aktif hari ini.\nTambahkan stok untuk mulai berjualan!',
            textAlign: TextAlign.center,
            style: AppTextStyle(
              color: AppColors.greyDark,
              fontSize: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const AppTextStyle(
        fontSize: AppTypography.titleLarge,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }
}
