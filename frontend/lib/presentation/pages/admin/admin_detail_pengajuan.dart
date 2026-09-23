import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/data/models/application_model.dart';
import 'package:haphap_fe/data/services/application_service.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/dialog/admin_reject_dialog.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';

class DetailPengajuanAdminPage extends StatefulWidget {
  final ApplicationModel application;

  const DetailPengajuanAdminPage({super.key, required this.application});

  @override
  State<DetailPengajuanAdminPage> createState() =>
      _DetailPengajuanAdminPageState();
}

class _DetailPengajuanAdminPageState extends State<DetailPengajuanAdminPage> {
  bool _isProcessing = false;

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'ROTI':
        return 'Bakery';
      case 'RESTORAN':
        return 'Restoran';
      case 'KAFE':
        return 'Kafe';
      case 'KEBUTUHAN':
        return 'Grocery';
      case 'JAJANAN':
        return 'Jajanan';
      case 'PENUTUP':
        return 'Dessert';
      default:
        return cat;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Tidak dapat membuka dokumen.');
    }
  }

  Future<void> _approve() async {
    setState(() => _isProcessing = true);
    try {
      await ApplicationService.updateStatus(
        widget.application.applicationId,
        status: 'APPROVED',
      );
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Pengajuan berhasil diterima!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Gagal menerima pengajuan: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject(String rejectNote) async {
    await ApplicationService.updateStatus(
      widget.application.applicationId,
      status: 'REJECTED',
      rejectNote: rejectNote,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    AppSnackbar.showSuccess(context, 'Pengajuan berhasil ditolak.');
    context.pop();
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (_) => AdminRejectDialog(onSubmit: _reject),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final isPending = app.status == 'PENDING';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildTopHeader(app),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.none,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Informasi Pemohon'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoCard([
                    _InfoRow(icon: Icons.person_outline, text: app.userName),
                    _InfoRow(icon: Icons.email_outlined, text: app.userEmail),
                    _InfoRow(icon: Icons.phone_outlined, text: app.userPhone),
                  ]),

                  const SizedBox(height: AppSpacing.xxl),

                  _buildSectionTitle('Detail Operasional'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoCard([
                    _InfoRow(
                      icon: Icons.access_time,
                      text: '${app.openTime} - ${app.closeTime}',
                    ),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: app.address,
                    ),
                    _InfoRow(icon: Icons.phone_outlined, text: app.phone),
                    if (app.description != null && app.description!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.notes_outlined,
                        text: app.description!,
                      ),
                  ]),

                  const SizedBox(height: AppSpacing.xxl),

                  _buildSectionTitle('Informasi Bank'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoCard([
                    _InfoRow(
                      icon: Icons.account_balance_outlined,
                      text: app.bankType,
                    ),
                    _InfoRow(
                      icon: Icons.credit_card_outlined,
                      text: app.bankAccount,
                    ),
                    _InfoRow(icon: Icons.badge_outlined, text: app.bankHolder),
                  ]),

                  const SizedBox(height: AppSpacing.xxl),

                  _buildSectionTitle('Dokumen'),
                  const SizedBox(height: AppSpacing.md),
                  _buildDocumentTile(app.document),

                  if (app.status == 'REJECTED' &&
                      app.rejectNote != null &&
                      app.rejectNote!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _buildSectionTitle('Catatan Penolakan'),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.06),
                        borderRadius: AppRadii.md,
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        app.rejectNote!,
                        style: const AppTextStyle(
                          fontSize: AppTypography.bodyMedium,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.largeSection),
                ],
              ),
            ),
          ),

          if (isPending) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTopHeader(ApplicationModel app) {
    final hasAvatar = app.avatar != null && app.avatar!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: AppRadii.sheetRadius,
          bottomRight: AppRadii.sheetRadius,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
              ),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: AppSizes.iconLargeMinus,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadii.lg,
                  boxShadow: AppShadows.card,
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: AppSizes.avatarCompact,
                      height: AppSizes.avatarCompact,
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.md,
                        image: hasAvatar
                            ? DecorationImage(
                                image: NetworkImage(app.avatar!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: hasAvatar
                          ? null
                          : Center(
                              child: Text(
                                app.merchantName.isNotEmpty
                                    ? app.merchantName[0].toUpperCase()
                                    : 'M',
                                style: const AppTextStyle(
                                  fontSize: AppTypography.headlineMedium,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.merchantName,
                            style: const AppTextStyle(
                              fontSize: AppTypography.bodyLarge,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          if (app.merchantOwner.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              app.merchantOwner,
                              style: const AppTextStyle(
                                fontSize: AppTypography.labelMedium,
                                color: AppColors.greyDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Diajukan: ${_formatDate(app.createdAt)}',
                            style: const AppTextStyle(
                              fontSize: AppTypography.labelMedium,
                              color: AppColors.greyDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: app.categories.map((cat) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.greyLight,
                                  ),
                                  borderRadius: AppRadii.sheet,
                                ),
                                child: Text(
                                  _categoryLabel(cat),
                                  style: const AppTextStyle(
                                    fontSize: AppTypography.labelMedium,
                                    color: AppColors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const AppTextStyle(
        fontSize: AppTypography.titleMedium,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.lg,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(row.icon, size: AppSizes.iconSm, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    row.text,
                    style: const AppTextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentTile(String documentUrl) {
    return GestureDetector(
      onTap: () => _openDocument(documentUrl),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadii.lg,
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.compactTouchTarget,
              height: AppSizes.compactTouchTarget,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: AppRadii.md,
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: AppSizes.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dokumen Pengajuan',
                    style: AppTextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Ketuk untuk membuka dokumen',
                    style: AppTextStyle(
                      fontSize: AppTypography.labelMedium,
                      color: AppColors.greyDark,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              size: AppSizes.iconSm,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppShadows.surfaceTop,
      ),
      child: Row(
        children: [
          Expanded(
            child: HapHapButton(
              text: 'Tolak',
              isExpanded: true,
              isOutline: true,
              onPressed: _isProcessing ? null : _showRejectDialog,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: HapHapButton(
              text: 'Terima',
              isExpanded: true,
              isLoading: _isProcessing,
              onPressed: _approve,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
}
