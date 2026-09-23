import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/data/services/application_service.dart';
import 'package:haphap_fe/presentation/widgets/buttons/button.dart';
import 'package:haphap_fe/presentation/widgets/headers/page_header.dart';
import 'package:haphap_fe/presentation/widgets/inputs/dropdown_field.dart';
import 'package:haphap_fe/presentation/widgets/inputs/file_upload_field.dart';
import 'package:haphap_fe/presentation/widgets/inputs/text_fields.dart';
import 'package:haphap_fe/presentation/widgets/navigations/stepper_indicator.dart';
import 'package:haphap_fe/presentation/widgets/feedback/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';

class MerchantRegistrationPage extends StatefulWidget {
  const MerchantRegistrationPage({super.key});

  @override
  State<MerchantRegistrationPage> createState() =>
      _MerchantRegistrationPageState();
}

class _MerchantRegistrationPageState extends State<MerchantRegistrationPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  final _ownerNameCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _openTimeCtrl = TextEditingController();
  final _closeTimeCtrl = TextEditingController();

  String? _selectedCategory;
  String? _selectedBank;
  final _accountNumberCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();

  XFile? _avatarFile;
  XFile? _documentFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    _ownerNameCtrl.dispose();
    _businessNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    _openTimeCtrl.dispose();
    _closeTimeCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountHolderCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_step1FormKey.currentState!.validate()) {
        if (_selectedCategory == null) {
          _showErrorSnackBar('Pilih kategori merchant terlebih dahulu');
          return;
        }
        if (_openTimeCtrl.text.isEmpty || _closeTimeCtrl.text.isEmpty) {
          _showErrorSnackBar('Waktu operasional harus diisi');
          return;
        }
        _moveToStep(1);
      }
    } else if (_currentStep == 1) {
      if (_selectedBank == null) {
        _showErrorSnackBar('Pilih bank terlebih dahulu');
        return;
      }
      if (_step2FormKey.currentState!.validate()) {
        _moveToStep(2);
      }
    }
  }

  void _moveToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hour:$minute';
      });
    }
  }

  Future<void> _pickFile(bool isDocument) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final length = await pickedFile.length();
        if (length > 5 * 1024 * 1024) {
          _showErrorSnackBar('Ukuran file maksimal 5 MB');
          return;
        }

        setState(() {
          if (isDocument) {
            _documentFile = pickedFile;
          } else {
            _avatarFile = pickedFile;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih file: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    AppSnackbar.showError(context, message);
  }

  Future<void> _submitApplication() async {
    if (_documentFile == null) {
      _showErrorSnackBar('Dokumen (Proposal/Izin) wajib diunggah');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fields = {
        'merchantName': _businessNameCtrl.text,
        'merchantOwner': _ownerNameCtrl.text,
        'address': _addressCtrl.text,
        'latitude': '-6.2',
        'longitude': '106.8',
        'openTime': _openTimeCtrl.text,
        'closeTime': _closeTimeCtrl.text,
        'phone': _phoneCtrl.text,
        'categories': _selectedCategory!,
        'bankType': _selectedBank!,
        'bankAccount': _accountNumberCtrl.text,
        'bankHolder': _accountHolderCtrl.text,
      };

      if (_descriptionCtrl.text.isNotEmpty) {
        fields['description'] = _descriptionCtrl.text;
      }

      await ApplicationService.createApplication(
        fields: fields,
        documentPath: _documentFile!.path,
        avatarPath: _avatarFile?.path,
      );

      if (mounted) {
        AppSnackbar.showSuccess(context, 'Pendaftaran berhasil dikirim!');
        context.pop();
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: HapHapPageHeader(title: 'Merchant'),
        ),
      ),
      body: Column(
        children: [
          HapHapStepperIndicator(
            currentStep: _currentStep,
            totalSteps: 3,
            labels: const ['Detail Bisnis', 'Detail Bank', 'Dokumen'],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Bisnis',
              style: AppTextStyle(
                fontSize: AppTypography.titleMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapTextField(
              labelText: 'Nama Pemilik',
              hintText: 'Masukkan nama lengkap pemilik',
              controller: _ownerNameCtrl,
              isRequired: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapTextField(
              labelText: 'Nama Bisnis',
              hintText: 'Masukkan nama bisnis',
              controller: _businessNameCtrl,
              isRequired: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapTextField(
              labelText: 'Telepon Bisnis',
              hintText: 'Masukkan nomor telepon bisnis',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              isRequired: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapTextField(
              labelText: 'Email Bisnis',
              hintText: 'Masukkan email bisnis',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapTextField(
              labelText: 'Alamat Bisnis',
              hintText: 'Masukkan alamat lengkap',
              controller: _addressCtrl,
              isRequired: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapTextField(
              labelText: 'Deskripsi',
              hintText: 'Masukkan deskripsi bisnis (opsional)',
              controller: _descriptionCtrl,
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapDropdownField(
              labelText: 'Kategori Merchant',
              hintText: 'Masukkan kategori',
              value: _selectedCategory,
              isRequired: true,
              options: const [
                'ROTI',
                'RESTORAN',
                'KAFE',
                'KEBUTUHAN',
                'JAJANAN',
                'PENUTUP',
              ],
              onSelected: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text(
              'Waktu Operasional',
              style: AppTextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(_openTimeCtrl),
                    child: IgnorePointer(
                      child: HapHapTextField(
                        labelText: 'Buka',
                        hintText: 'Masukkan jam buka',
                        controller: _openTimeCtrl,
                        isRequired: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(_closeTimeCtrl),
                    child: IgnorePointer(
                      child: HapHapTextField(
                        labelText: 'Tutup',
                        hintText: 'Masukkan jam tutup',
                        controller: _closeTimeCtrl,
                        isRequired: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Rekening',
              style: AppTextStyle(
                fontSize: AppTypography.titleMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapDropdownField(
              labelText: 'Nama Bank',
              hintText: 'Masukkan bank',
              value: _selectedBank,
              isRequired: true,
              options: const [
                'BCA',
                'BNI',
                'MANDIRI',
                'BRI',
                'CIMB',
                'DANAMON',
                'PERMATA',
                'BTN',
              ],
              onSelected: (val) {
                setState(() {
                  _selectedBank = val;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapTextField(
              labelText: 'Nomor Rekening',
              hintText: 'Masukkan nomor rekening',
              controller: _accountNumberCtrl,
              keyboardType: TextInputType.number,
              isRequired: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            HapHapTextField(
              labelText: 'Nama Pemilik Rekening',
              hintText: 'Masukkan nama pemilik rekening',
              controller: _accountHolderCtrl,
              isRequired: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Wajib diisi' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Dokumen',
            style: AppTextStyle(
              fontSize: AppTypography.titleMedium,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Silakan unggah dokumen yang diperlukan untuk pendaftaran merchant.',
            style: AppTextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.greyDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          HapHapFileUploadField(
            labelText: 'Avatar / Logo Bisnis (Opsional)',
            selectedFileName: _avatarFile?.name,
            onFileSelected: () => _pickFile(false),
            onClear: () {
              setState(() {
                _avatarFile = null;
              });
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          HapHapFileUploadField(
            labelText: 'Dokumen (Proposal / Izin Bisnis)',
            isRequired: true,
            selectedFileName: _documentFile?.name,
            onFileSelected: () => _pickFile(true),
            onClear: () {
              setState(() {
                _documentFile = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppShadows.surfaceTop,
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: HapHapButton(
                text: 'Kembali',
                isOutline: true,
                onPressed: () => _moveToStep(_currentStep - 1),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.lg),
          Expanded(
            flex: 2,
            child: HapHapButton(
              text: _currentStep == 2
                  ? 'Kirim Pendaftaran'
                  : 'Langkah Berikutnya',
              isLoading: _isLoading,
              onPressed: _currentStep == 2 ? _submitApplication : _nextStep,
            ),
          ),
        ],
      ),
    );
  }
}
