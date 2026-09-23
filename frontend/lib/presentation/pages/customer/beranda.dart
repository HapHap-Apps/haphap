import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/constants/app_icons.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/core/network/token_manager.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/data/models/merchant_model.dart';
import 'package:haphap_fe/data/models/user_profile_model.dart';
import 'package:haphap_fe/data/services/merchant_service.dart';
import 'package:haphap_fe/data/services/user_service.dart';
import 'package:haphap_fe/presentation/widgets/buttons/beranda_merchant_category.dart';
import 'package:haphap_fe/presentation/widgets/cards/beranda_stats.dart';
import 'package:haphap_fe/presentation/widgets/cards/restaurant_card.dart';
import 'package:haphap_fe/presentation/widgets/inputs/search_bar.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroSection(),
            const _KategoriSection(),
            const SizedBox(height: _BerandaLayout.kategoriToSekitar),
            const _SekitarKamuSection(),
            const SizedBox(height: _BerandaLayout.bottomScrollPadding),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: _BerandaLayout.heroOrangeBgBottomCut,
          child: const _OrangeBackground(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: _BerandaLayout.heroTopPadding),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _BerandaLayout.heroHorizontalPadding,
              ),
              child: GestureDetector(
                onTap: () {
                  context.go(AppRoutes.jelajah);
                },
                child: const AbsorbPointer(
                  child: HapHapSearchBar(
                    hintText: _BerandaContent.searchHint,
                    prefixIconPath: AppIcons.magnifyingGlass,
                  ),
                ),
              ),
            ),
            const SizedBox(height: _BerandaLayout.heroSearchToTagline),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _BerandaLayout.heroHorizontalPadding,
              ),
              child: _TaglineWithMascot(),
            ),
            const SizedBox(height: _BerandaLayout.heroDiskonToCards),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _BerandaLayout.heroHorizontalPadding,
              ),
              child: const _StatsRow(),
            ),
            const SizedBox(height: _BerandaLayout.heroCardsToKategori),
          ],
        ),
      ],
    );
  }
}

class _OrangeBackground extends StatelessWidget {
  const _OrangeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: AppRadii.sheetRadius,
          bottomRight: AppRadii.sheetRadius,
        ),
      ),
    );
  }
}

class _TaglineWithMascot extends StatelessWidget {
  const _TaglineWithMascot();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mascotWidth = AppLayout.responsiveExtent(
          constraints.maxWidth,
          fraction: AppLayout.mascotWidthFraction,
          min: AppSizes.compactButtonWidth,
          max: AppSizes.mascotWidth,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  _BerandaContent.tagline,
                  style: AppTextStyle(
                    fontSize: AppTypography.titleLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    height: AppTypography.lineHeightNormal,
                  ),
                ),
                const SizedBox(height: _BerandaLayout.heroTaglineToDiskon),
                GestureDetector(
                  onTap: () {
                    context.go('${AppRoutes.aktivitas}?tab=2');
                  },
                  child: const Row(
                    children: [
                      Flexible(
                        child: Text(
                          _BerandaContent.discountCta,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle(
                            fontSize: AppTypography.bodyMedium,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.white,
                        size: AppSizes.iconXs,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: _BerandaLayout.mascotRight,
              top: _BerandaLayout.mascotTop,
              child: Image.asset(
                _BerandaContent.mascotPath,
                width: mascotWidth,
                height: mascotWidth * AppLayout.mascotAspectRatio,
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatsRow extends StatefulWidget {
  const _StatsRow();

  @override
  State<_StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<_StatsRow> {
  UserProfileModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final hasToken = await TokenManager.hasToken();
      if (!hasToken) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final user = await UserService.getMe();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      final value = amount / 1000000;
      return '${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      final value = amount / 1000;
      return '${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)}rb';
    }
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Row(
        children: [
          Expanded(
            child: HapHapStatsCard(
              title: _BerandaContent.statsSavingsTitle,
              prefixText: _BerandaContent.statsSavingsPrefix,
              mainValue: '...',
              valueColor: AppColors.success,
              subtitle: '',
            ),
          ),
          SizedBox(width: _BerandaLayout.statCardSpacing),
          Expanded(
            child: HapHapStatsCard(
              title: _BerandaContent.statsSavedTitle,
              mainValue: '...',
              valueColor: AppColors.primary,
              subtitle: '',
            ),
          ),
        ],
      );
    }

    final savingsValue = _user != null
        ? _formatCurrency(_user!.totalSaved)
        : '0';
    final portionValue = _user != null
        ? '${_user!.totalPortion} Porsi'
        : '0 Porsi';

    return Row(
      children: [
        Expanded(
          child: HapHapStatsCard(
            title: _BerandaContent.statsSavingsTitle,
            prefixText: _BerandaContent.statsSavingsPrefix,
            mainValue: savingsValue,
            valueColor: AppColors.success,
            subtitle: _BerandaContent.statsSavingsSubtitle,
          ),
        ),
        const SizedBox(width: _BerandaLayout.statCardSpacing),
        Expanded(
          child: HapHapStatsCard(
            title: _BerandaContent.statsSavedTitle,
            mainValue: portionValue,
            valueColor: AppColors.primary,
            subtitle: _BerandaContent.statsSavedSubtitle,
          ),
        ),
      ],
    );
  }
}

class _KategoriSection extends StatelessWidget {
  const _KategoriSection();

  void _navigateToJelajah(BuildContext context, String category) {
    context.go('${AppRoutes.jelajah}?category=$category');
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppLayout.pagePadding(context);
    final categories = <(String, String, String)>[
      (AppIcons.bakery, 'Bakery', 'ROTI'),
      (AppIcons.restaurant, 'Restoran', 'RESTORAN'),
      (AppIcons.cafe, 'Kafe', 'KAFE'),
      (AppIcons.grocery, 'Grocery', 'KEBUTUHAN'),
      (AppIcons.jajanan, 'Jajanan', 'JAJANAN'),
      (AppIcons.dessert, 'Dessert', 'PENUTUP'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const _SectionTitle(text: 'Kategori'),
        ),
        const SizedBox(height: _BerandaLayout.sectionTitleToContent),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final visibleCount =
                  (constraints.maxWidth / AppSizes.categoryCellMinWidth)
                      .floor()
                      .clamp(1, categories.length);
              final itemWidth = constraints.maxWidth / visibleCount;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final category in categories)
                      SizedBox(
                        key: ValueKey('home_category_${category.$2}'),
                        width: itemWidth,
                        child: HapHapCategoryButton(
                          iconPath: category.$1,
                          label: category.$2,
                          onTap: () => _navigateToJelajah(context, category.$3),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SekitarKamuSection extends StatefulWidget {
  const _SekitarKamuSection();

  @override
  State<_SekitarKamuSection> createState() => _SekitarKamuSectionState();
}

class _SekitarKamuSectionState extends State<_SekitarKamuSection> {
  List<MerchantModel> _merchants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMerchants();
  }

  Future<void> _fetchMerchants() async {
    try {
      final merchants = await MerchantService.fetchAll();
      if (!mounted) return;
      setState(() {
        _merchants = merchants;
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
        _error = 'Gagal memuat merchant.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _BerandaLayout.sectionHorizontalPadding,
          ),
          child: _SectionTitle(text: 'Sekitar Kamu'),
        ),
        const SizedBox(height: _BerandaLayout.sectionTitleToContent),
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _BerandaLayout.sectionHorizontalPadding,
          vertical: AppSpacing.lg,
        ),
        child: Text(
          _error!,
          style: const AppTextStyle(
            color: AppColors.error,
            fontSize: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    if (_merchants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _BerandaLayout.sectionHorizontalPadding,
          vertical: AppSpacing.lg,
        ),
        child: Text(
          'Belum ada merchant di sekitar kamu.',
          style: AppTextStyle(
            color: AppColors.greyDark,
            fontSize: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: _BerandaLayout.sectionHorizontalPadding,
      ),
      child: Row(
        children: _merchants.asMap().entries.map((entry) {
          final index = entry.key;
          final merchant = entry.value;

          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.push(
                    '${AppRoutes.detailRestoran}/${merchant.merchantId}',
                  );
                },
                child: HapHapRestaurantCard(
                  imageUrl: merchant.avatar ?? '',
                  distanceTime: merchant.address ?? '',
                  restaurantName: merchant.merchantName,
                  ratingText: merchant.rating != null
                      ? '${merchant.rating!.toStringAsFixed(1)} rating'
                      : 'Belum ada rating',
                ),
              ),
              if (index < _merchants.length - 1)
                const SizedBox(width: _BerandaLayout.restaurantCardSpacing),
            ],
          );
        }).toList(),
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
        fontSize: AppTypography.titleMedium,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }
}

class _BerandaLayout {
  static const double heroTopPadding = AppSpacing.heroTop;
  static const double heroHorizontalPadding = AppSpacing.xxl;
  static const double heroSearchToTagline = AppSpacing.section;
  static const double heroTaglineToDiskon = AppSpacing.lg;
  static const double heroDiskonToCards = AppSpacing.section;
  static const double heroCardsToKategori = AppSpacing.xxxl;
  static const double heroOrangeBgBottomCut = AppSpacing.largeSection;

  static const double mascotRight = -AppSpacing.xxxl;
  static const double mascotTop = -AppSizes.categoryButton;

  static const double statCardSpacing = AppSpacing.lg;
  static const double sectionHorizontalPadding = AppSpacing.xxl;
  static const double restaurantCardSpacing = AppSpacing.lg;
  static const double sectionTitleToContent = AppSpacing.lg;
  static const double kategoriToSekitar = AppSpacing.xxxl;
  static const double bottomScrollPadding = AppSpacing.screenBottom;
}

class _BerandaContent {
  static const String searchHint = 'Masukkan pencarian';
  static const String tagline = 'Selalu hemat beli\nmakanan pakai HapHap.';
  static const String discountCta = 'Lihat promo selengkapnya disini';
  static const String mascotPath = 'assets/images/puy_beranda1.png';

  static const String statsSavingsTitle = 'Berhasil Hemat';
  static const String statsSavingsPrefix = 'Rp ';
  static const String statsSavingsSubtitle = 'Total penghematan kamu';

  static const String statsSavedTitle = 'Berhasil Selamatin';
  static const String statsSavedSubtitle = 'Total porsi diselamatkan';
}
