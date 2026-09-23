import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/data/models/application_model.dart';
import 'package:haphap_fe/data/services/application_service.dart';
import 'package:haphap_fe/presentation/widgets/cards/admin_application_card.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';
import 'package:haphap_fe/presentation/widgets/navigations/tab_bar.dart';

class PengajuanAdminPage extends StatefulWidget {
  const PengajuanAdminPage({super.key});

  @override
  State<PengajuanAdminPage> createState() => _PengajuanAdminPageState();
}

class _PengajuanAdminPageState extends State<PengajuanAdminPage> {
  int _currentTabIndex = 0;

  List<ApplicationModel> _applications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);
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
        _error = 'Gagal memuat pengajuan.';
        _isLoading = false;
      });
    }
  }

  List<ApplicationModel> get _filteredApplications {
    switch (_currentTabIndex) {
      case 0:
        return _applications.where((a) => a.status == 'PENDING').toList();
      case 1:
        return _applications.where((a) => a.status == 'APPROVED').toList();
      case 2:
        return _applications.where((a) => a.status == 'REJECTED').toList();
      default:
        return _applications;
    }
  }

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
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: HapHapPageHeader(
                title: 'Pengajuan',
                showBackButton: false,
                fontSize: AppTypography.headlineSmall,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: HapHapTabBar(
                currentIndex: _currentTabIndex,
                tabs: const ['Menunggu', 'Diterima', 'Ditolak'],
                onTap: (index) {
                  setState(() => _currentTabIndex = index);
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _error != null
                  ? Center(child: Text(_error!))
                  : RefreshIndicator(
                      onRefresh: _fetchApplications,
                      color: AppColors.primary,
                      child: _buildList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final list = _filteredApplications;

    if (list.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada pengajuan di sini.',
          style: AppTextStyle(
            color: AppColors.greyDark,
            fontSize: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      itemCount: list.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return const SizedBox(height: AppSpacing.bottomClearance);
        }

        final app = list[index];
        return AdminApplicationCard(
          merchantName: app.merchantName,
          applicantName: app.userName,
          dateText: _formatDate(app.createdAt),
          status: app.status,
          avatarUrl: app.avatar,
          onTap: () async {
            await context.push(AppRoutes.adminDetailPengajuan, extra: app);
            _fetchApplications();
          },
        );
      },
    );
  }
}
