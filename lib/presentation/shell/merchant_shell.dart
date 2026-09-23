import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/presentation/widgets/navigations/navigation_bar.dart';

class MerchantShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MerchantShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return HapHapNavigationScaffold(
      body: navigationShell,
      currentIndex: navigationShell.currentIndex,
      type: NavBarType.merchant,
      onTap: navigationShell.goBranch,
    );
  }
}
