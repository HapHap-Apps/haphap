import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/cards/akun_statistik_pribadi.dart';

import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';
import 'package:haphap_fe/data/services/user_service.dart';
import 'package:haphap_fe/data/models/user_profile_model.dart';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  UserProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final profile = await UserService.getMe();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: HapHapPageHeader(title: 'Statistik'),
              ),

              const SizedBox(height: AppSpacing.lg),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: HapHapStatistikPribadiCard(
                    title: 'Kamu berhasil menghemat',
                    valuePrefix: 'Rp ',
                    value: _profile != null
                        ? _formatNumber(_profile!.totalSaved)
                        : '0',
                    valueColor: AppColors.success,
                    dateText: 'Sejak bergabung',
                    imagePath: 'assets/images/piggy_bank.png',
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: HapHapStatistikPribadiCard(
                    title: 'Kamu udah menyelamatkan',
                    valuePrefix: '',
                    value: _profile != null
                        ? '${_profile!.totalPortion} Porsi'
                        : '0 Porsi',
                    valueColor: AppColors.primary,
                    dateText: 'Sejak bergabung',
                    imagePath: 'assets/images/puy_kenyang.png',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
