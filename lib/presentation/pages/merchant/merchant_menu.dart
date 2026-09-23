import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/cards/merchant_add_menu.dart';
import 'package:haphap_fe/presentation/widgets/cards/merchant_menu_list.dart';
import 'package:haphap_fe/presentation/widgets/dialog/merchant_delete_menu_dialog.dart';
import 'package:haphap_fe/presentation/widgets/dialog/merchant_edit_menu_dialog.dart';
import 'package:haphap_fe/presentation/widgets/inputs/search_bar.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';

import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';
import 'package:haphap_fe/data/services/menu_service.dart';
import 'package:haphap_fe/data/models/merchant_model.dart';
import 'package:haphap_fe/core/network/api_client.dart';

class MenuMerchantPage extends StatefulWidget {
  const MenuMerchantPage({super.key});

  @override
  State<MenuMerchantPage> createState() => _MenuMerchantPageState();
}

class _MenuMerchantPageState extends State<MenuMerchantPage> {
  List<MenuItemModel> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUnauthorized = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _isUnauthorized = false;
      });
    }

    try {
      final items = await MenuService.getAllMenus();
      if (!mounted) return;
      final activeItems = items.where((m) => m.isActive).toList();
      setState(() {
        _items = activeItems;
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
            'Tidak dapat memuat data menu. Periksa koneksi internet kamu.';
      });
    }
  }

  Future<void> _onRefresh() async {
    try {
      final items = await MenuService.getAllMenus();
      if (!mounted) return;
      final activeItems = items.where((m) => m.isActive).toList();
      setState(() {
        _items = activeItems;
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
            'Tidak dapat memuat data menu. Periksa koneksi internet kamu.';
      });
    }
  }

  void _showAddMenuDialog() {
    showDialog(
      context: context,
      builder: (context) => const HapHapAddMenuDialog(),
    ).then((_) => _fetchItems());
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  List<MenuItemModel> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    final query = _searchQuery.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          (item.description?.toLowerCase().contains(query) ?? false);
    }).toList();
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: HapHapPageHeader(
                title: 'Menu',
                showBackButton: false,
                fontSize: AppTypography.headlineSmall,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: HapHapSearchBar(
                hintText: 'Masukkan nama menu',
                prefixIconPath: 'assets/icons/magnifying_glass.svg',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Expanded(child: _buildContent()),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenuDialog,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: AppElevations.card,
        child: const Icon(
          Icons.add,
          color: AppColors.white,
          size: AppSizes.iconLg,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    final filtered = _filteredItems;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: AppSizes.touchTarget,
              color: AppColors.greyDark,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tidak ditemukan menu "$_searchQuery"',
              textAlign: TextAlign.center,
              style: const AppTextStyle(
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
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
          bottom: AppSpacing.bottomClearance,
        ),
        itemCount: filtered.length,

        separatorBuilder: (context, index) => const Divider(
          height: AppSizes.iconLg,
          thickness: 1,
          color: AppColors.surfaceBorder,
        ),

        itemBuilder: (context, index) {
          final item = filtered[index];
          final menuTitle = item.name;
          final menuDesc = item.description ?? '';
          final menuPrice = 'Rp ${_formatPrice(item.originalPrice)}';

          return HapHapMerchantMenuItemCard(
            title: menuTitle,
            description: menuDesc,
            price: menuPrice,
            imageUrl: (item.image != null && item.image!.isNotEmpty)
                ? item.image!
                : '',

            onEdit: () {
              showDialog(
                context: context,
                builder: (context) => HapHapEditMenuDialog(
                  menuItemId: item.menuItemId,
                  initialName: menuTitle,
                  initialPrice: menuPrice,
                  initialDesc: menuDesc,
                ),
              ).then((_) => _fetchItems());
            },

            onDelete: () {
              showDialog(
                context: context,
                builder: (context) => HapHapDeleteMenuDialog(
                  menuName: menuTitle,
                  menuItemId: item.menuItemId,
                ),
              ).then((_) => _fetchItems());
            },
          );
        },
      ),
    );
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
                    _fetchItems();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.restaurant_menu_outlined,
            size: AppSizes.touchTarget,
            color: AppColors.greyDark,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada menu.\nTambahkan menu pertamamu!',
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
