import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/data/models/application_model.dart';
import 'package:haphap_fe/data/services/application_service.dart';
import 'package:haphap_fe/presentation/widgets/cards/admin_application_card.dart';

class _AdminBerandaLayout {
  static const double heroTopPadding = AppSpacing.huge;
  static const double heroHorizontalPadding = AppSpacing.xxl;
  static const double titleToGrid = AppSpacing.xxl;
  static const double gridCardSpacing = AppSpacing.lg;
  static const double gridCardHeight = AppSizes.adminGridCardHeight;
  static const double heroPaddingBottom = AppSpacing.xxxl;
  static const double sectionHorizontalPadding = AppSpacing.xxl;
  static const double sectionTitleToContent = AppSpacing.lg;
  static const double bottomScrollPadding = AppSpacing.screenBottom;
}

class BerandaAdminPage extends StatefulWidget {
  const BerandaAdminPage({super.key});

  @override
  State<BerandaAdminPage> createState() => _BerandaAdminPageState();
}

class _BerandaAdminPageState extends State<BerandaAdminPage> {
  List<ApplicationModel> _applications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      final apps = await ApplicationService.fetchAll();
      if (!mounted) return;
      setState(() {
        _applications = apps;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data pengajuan.';
        _isLoading = false;
      });
    }
  }

  int get _totalCount => _applications.length;
  int get _pendingCount =>
      _applications.where((a) => a.status == 'PENDING').length;
  int get _approvedCount =>
      _applications.where((a) => a.status == 'APPROVED').length;
  int get _rejectedCount =>
      _applications.where((a) => a.status == 'REJECTED').length;

  List<ApplicationModel> get _latestApplications =>
      _applications.take(5).toList();

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(child: Text(_error!))
          : RefreshIndicator(
              onRefresh: _fetchApplications,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildPengajuanTerbaruSection(),
                    const SizedBox(
                      height: _AdminBerandaLayout.bottomScrollPadding,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: AppRadii.heroRadius,
          bottomRight: AppRadii.heroRadius,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _AdminBerandaLayout.heroHorizontalPadding,
            _AdminBerandaLayout.heroTopPadding,
            _AdminBerandaLayout.heroHorizontalPadding,
            _AdminBerandaLayout.heroPaddingBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Sistem',
                style: AppTextStyle(
                  fontSize: AppTypography.headlineSmall,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  height: AppTypography.lineHeightNormal,
                ),
              ),

              const SizedBox(height: _AdminBerandaLayout.titleToGrid),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Total Pengajuan',
                      value: _totalCount.toString(),
                      valueColor: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: _AdminBerandaLayout.gridCardSpacing),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Menunggu Validasi',
                      value: _pendingCount.toString(),
                      valueColor: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: _AdminBerandaLayout.gridCardSpacing),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Diterima',
                      value: _approvedCount.toString(),
                      valueColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: _AdminBerandaLayout.gridCardSpacing),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Ditolak',
                      value: _rejectedCount.toString(),
                      valueColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      height: _AdminBerandaLayout.gridCardHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lg,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyle(
              fontSize: AppTypography.displaySmall,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const AppTextStyle(
              fontSize: AppTypography.labelMedium,
              color: AppColors.greyDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengajuanTerbaruSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _AdminBerandaLayout.sectionHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengajuan Terbaru',
                style: AppTextStyle(
                  fontSize: AppTypography.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.adminPengajuan),
                child: const Text(
                  'Lihat Semua',
                  style: AppTextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: _AdminBerandaLayout.sectionTitleToContent),

          if (_latestApplications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'Belum ada pengajuan.',
                style: AppTextStyle(color: AppColors.greyDark),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _latestApplications.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final app = _latestApplications[index];
                return AdminApplicationCard(
                  merchantName: app.merchantName,
                  applicantName: app.userName,
                  dateText: _formatDate(app.createdAt),
                  status: app.status,
                  avatarUrl: app.avatar,
                  onTap: () =>
                      context.push(AppRoutes.adminDetailPengajuan, extra: app),
                );
              },
            ),
        ],
      ),
    );
  }
}
