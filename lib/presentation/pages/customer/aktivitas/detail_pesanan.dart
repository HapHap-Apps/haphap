import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';
import 'package:haphap_fe/presentation/widgets/cards/aktivitas_status_pesanan.dart';
import 'package:haphap_fe/presentation/widgets/cards/aktivitas_qr.dart';
import 'package:haphap_fe/presentation/widgets/cards/aktivitas_detail_pesanan.dart';
import 'package:haphap_fe/presentation/widgets/cards/aktivitas_rincian_pembayaran.dart';

import 'package:haphap_fe/data/models/order_model.dart';
import 'package:haphap_fe/data/services/order_service.dart';

class DetailPesananPage extends StatefulWidget {
  final String? orderId;

  const DetailPesananPage({super.key, this.orderId});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchOrder(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrder({bool silent = false}) async {
    if (widget.orderId == null) {
      setState(() {
        _error = 'Order ID tidak ditemukan';
        _isLoading = false;
      });
      return;
    }

    try {
      final order = await OrderService.fetchOrder(widget.orderId!);
      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoading = false;
      });

      if (order.status == 'COMPLETED' || order.status == 'CANCELLED') {
        _pollTimer?.cancel();
      }
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1;

    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';

    if (isToday) return 'Hari ini, $timeStr';
    if (isYesterday) return 'Kemarin, $timeStr';

    return '${date.day}/${date.month}/${date.year}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                top: AppSpacing.loose,
                bottom: AppSpacing.sm,
              ),
              child: HapHapPageHeader(title: 'Detail Pesanan'),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _order == null
                  ? const Center(child: Text('Pesanan tidak ditemukan'))
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final order = _order!;

    String mainTitle;
    String imagePath;
    String dateStatus;

    switch (order.status) {
      case 'PENDING':
        mainTitle = 'Menunggu Pembayaran';
        imagePath = 'assets/images/on_process.png';
        dateStatus = '${_formatDate(order.createdAt)} · Menunggu';
        break;
      case 'PROCESSING':
        mainTitle = 'Menunggu Dikonfirmasi';
        imagePath = 'assets/images/on_process.png';
        dateStatus = '${_formatDate(order.createdAt)} · Menunggu Dikonfirmasi';
        break;
      case 'READY':
        if (order.qrCode != null) {
          mainTitle = 'Siap Diambil';
          imagePath = 'assets/images/done.png';
          dateStatus = '${_formatDate(order.createdAt)} · Siap Diambil';
        } else {
          mainTitle = 'Sedang Disiapkan';
          imagePath = 'assets/images/on_process.png';
          dateStatus = '${_formatDate(order.createdAt)} · Disiapkan';
        }
        break;
      case 'COMPLETED':
        mainTitle = 'Pesanan Selesai';
        imagePath = 'assets/images/done.png';
        dateStatus = '${_formatDate(order.createdAt)} · Selesai';
        break;
      case 'CANCELLED':
        mainTitle = 'Pesanan Dibatalkan';
        imagePath = 'assets/images/on_process.png';
        dateStatus = '${_formatDate(order.createdAt)} · Dibatalkan';
        break;
      default:
        mainTitle = 'Pesanan Diproses';
        imagePath = 'assets/images/on_process.png';
        dateStatus = '${_formatDate(order.createdAt)} · Diproses';
    }

    final avatar =
        (order.merchant?.avatar != null && order.merchant!.avatar!.isNotEmpty)
        ? order.merchant!.avatar!
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HapHapStatusPesananCard(
            dateStatusText: dateStatus,
            mainTitle: mainTitle,
            imagePath: imagePath,
          ),

          const SizedBox(height: AppSpacing.xxxl),

          if (order.status == 'READY' && order.qrCode != null) ...[
            Center(child: HapHapQRCodeCard(qrToken: order.qrCode!)),
            const SizedBox(height: AppSpacing.xxxl),
          ],

          const Text(
            'Detail Pesanan',
            style: AppTextStyle(
              fontSize: AppTypography.bodyLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          HapHapDetailPesananCard(
            restaurantName: order.merchant?.merchantName ?? 'Merchant',
            restaurantLogoUrl: avatar,
            items: order.orderItems
                .map(
                  (item) => HapHapOrderItem(
                    name: item.name,
                    description: '',
                    price: 'Rp ${_formatPrice(item.discountPrice)}',
                    quantity: item.quantity,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          const Text(
            'Rincian Pembayaran',
            style: AppTextStyle(
              fontSize: AppTypography.bodyLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          HapHapRincianPembayaran(
            paymentMethod: order.isOnlinePayment ? 'QRIS' : 'Tunai di Kasir',
            totalPrice: 'Rp ${_formatPrice(order.totalAmount)}',
            orderNumber: order.orderId,
            paymentTime: order.paidAt != null
                ? _formatDate(order.paidAt!)
                : '-',
            completionTime: order.completedAt != null
                ? _formatDate(order.completedAt!)
                : '-',
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
