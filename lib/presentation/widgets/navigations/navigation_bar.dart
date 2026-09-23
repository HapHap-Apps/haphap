import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/core/constants/app_icons.dart';

enum NavBarType { user, merchant, admin }

class HapHapNavigationScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final NavBarType type;

  const HapHapNavigationScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTap,
    this.type = NavBarType.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // The tab content has an interaction-safe viewport, while this white
      // underlay lets rounded sheet surfaces continue behind the floating bar.
      backgroundColor: AppColors.white,
      body: Padding(
        padding: EdgeInsets.only(
          bottom: AppLayout.floatingNavBarClearance(context),
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: body,
        ),
      ),
      bottomNavigationBar: HapHapNavBar(
        currentIndex: currentIndex,
        type: type,
        onTap: onTap,
      ),
    );
  }
}

class HapHapNavBar extends StatefulWidget {
  static const surfaceKey = ValueKey('floating_navigation_surface');

  final int currentIndex;
  final ValueChanged<int> onTap;
  final NavBarType type;

  const HapHapNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.type = NavBarType.user,
  });

  @override
  State<HapHapNavBar> createState() => _HapHapNavBarState();
}

class _HapHapNavBarState extends State<HapHapNavBar> {
  bool _tapLocked = false;

  void _handleTap(int index) {
    if (_tapLocked || index == widget.currentIndex) return;

    _tapLocked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tapLocked = false;
    });
    WidgetsBinding.instance.ensureVisualUpdate();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.none,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Container(
        key: HapHapNavBar.surfaceKey,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadii.sheet,
          boxShadow: AppShadows.surfaceTop,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in _items)
                Expanded(child: _buildNavItem(item.$1, item.$2, item.$3)),
            ],
          ),
        ),
      ),
    );
  }

  List<(int, String, String)> get _items => switch (widget.type) {
    NavBarType.user => [
      (0, AppIcons.navBeranda, 'Beranda'),
      (1, AppIcons.navJelajah, 'Jelajah'),
      (2, AppIcons.navAktivitas, 'Aktivitas'),
      (3, AppIcons.navAkun, 'Akun'),
    ],
    NavBarType.merchant => [
      (0, AppIcons.navBeranda, 'Beranda'),
      (1, AppIcons.navMenu, 'Menu'),
      (2, AppIcons.navAktivitas, 'Aktivitas'),
      (3, AppIcons.navAkun, 'Akun'),
    ],
    NavBarType.admin => [
      (0, AppIcons.navBeranda, 'Beranda'),
      (1, AppIcons.navAktivitas, 'Pengajuan'),
      (2, AppIcons.navAkun, 'Akun'),
    ],
  };

  Widget _buildNavItem(int index, String iconPath, String label) {
    final isActive = widget.currentIndex == index;

    return Semantics(
      key: ValueKey('nav_item_$label'),
      selected: isActive,
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleTap(index),
        child: SizedBox(
          height: AppSizes.navBarItemHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.iconLg,
                height: AppSizes.progressIndicator,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: AppRadii.xsRadius,
                    bottomRight: AppRadii.xsRadius,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    isActive ? AppColors.primary : AppColors.greyDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppTextStyle(
                      fontSize: AppTypography.labelMedium,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.primary : AppColors.greyDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
