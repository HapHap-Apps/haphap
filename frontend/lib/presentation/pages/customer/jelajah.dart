import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/constants/app_icons.dart';
import 'package:haphap_fe/core/network/api_client.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/data/models/merchant_model.dart';
import 'package:haphap_fe/data/services/merchant_service.dart';

import 'package:haphap_fe/presentation/widgets/inputs/search_bar.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/buttons/beranda_category.dart';
import 'package:haphap_fe/presentation/widgets/cards/restaurant_card.dart';

class JelajahPage extends StatefulWidget {
  final String? initialCategory;

  const JelajahPage({super.key, this.initialCategory});

  @override
  State<JelajahPage> createState() => _JelajahPageState();
}

class _JelajahPageState extends State<JelajahPage> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All',
    'Bakery',
    'Restoran',
    'Kafe',
    'Grocery',
    'Jajanan',
    'Dessert',
  ];

  final Map<String, String> _categoryEnumMap = {
    'Bakery': 'ROTI',
    'Restoran': 'RESTORAN',
    'Kafe': 'KAFE',
    'Grocery': 'KEBUTUHAN',
    'Jajanan': 'JAJANAN',
    'Dessert': 'PENUTUP',
  };

  List<MerchantModel> _merchants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _applyInitialCategory();
    _fetchMerchants();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant JelajahPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      _applyInitialCategory();
    }
  }

  void _applyInitialCategory() {
    if (widget.initialCategory != null) {
      final entry = _categoryEnumMap.entries.firstWhere(
        (e) => e.value == widget.initialCategory,
        orElse: () => const MapEntry('All', ''),
      );

      final index = _categories.indexOf(entry.key);
      if (index != -1) {
        setState(() {
          _selectedCategoryIndex = index;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
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
        _error = 'Gagal memuat data merchant. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  List<MerchantModel> get _filteredMerchants {
    List<MerchantModel> result = _merchants;

    if (_selectedCategoryIndex > 0) {
      final selectedCategoryLabel = _categories[_selectedCategoryIndex];
      final backendEnum = _categoryEnumMap[selectedCategoryLabel];

      if (backendEnum != null) {
        result = result.where((merchant) {
          return merchant.categories.contains(backendEnum);
        }).toList();
      }
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((merchant) {
        return merchant.merchantName.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: HapHapSearchBar(
                hintText: 'Masukkan pencarian',
                prefixIconPath: AppIcons.magnifyingGlass,
                controller: _searchController,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Row(
                children: List.generate(_categories.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: HapHapCategoryPill(
                      label: _categories[index],
                      isSelected: _selectedCategoryIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Expanded(child: _buildMerchantList()),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: AppSizes.touchTarget,
                color: AppColors.greyLight,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const AppTextStyle(
                  color: AppColors.greyDark,
                  fontSize: AppTypography.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              HapHapButton(
                text: 'Coba Lagi',
                isText: true,
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchMerchants();
                },
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredMerchants;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: AppSizes.touchTarget,
                color: AppColors.greyLight,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _searchController.text.trim().isNotEmpty ||
                        _selectedCategoryIndex > 0
                    ? 'Tidak ada merchant yang sesuai dengan pencarian kamu.'
                    : 'Belum ada merchant yang tersedia saat ini.',
                textAlign: TextAlign.center,
                style: const AppTextStyle(
                  color: AppColors.greyDark,
                  fontSize: AppTypography.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == filtered.length) {
          return const SizedBox(height: AppSpacing.huge);
        }

        final merchant = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: GestureDetector(
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
        );
      },
    );
  }
}
