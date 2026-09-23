import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haphap_fe/core/router/app_routes.dart';
import 'package:haphap_fe/core/theme/app_colors.dart';
import 'package:haphap_fe/presentation/widgets/buttons/onboarding_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<OnboardingData> _pages = [
    OnboardingData(
      imagePath: 'assets/images/onboarding-page1.png',
      backgroundColor: AppColors.primary,
      titleParts: [
        TextPart('Makan ', false),
        TextPart('Mewah', true),
        TextPart(', Harga ', false),
        TextPart('Murah', true),
        TextPart('!', false),
      ],
      description:
          'Nikmati makanan enak dari restoran dan warung pilihanmu dengan diskon besar-besaran tiap harinya!',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding-page2.png',
      backgroundColor: AppColors.primary,
      titleParts: [
        TextPart('Jadi ', false),
        TextPart('Pahlawan', true),
        TextPart(' Modal ', false),
        TextPart('Ngunyah', true),
        TextPart('!', false),
      ],
      description:
          'Setiap porsi yang kamu beli, menyelamatkan makanan enak yang terbuang sia-sia.',
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding-page3.png',
      backgroundColor: AppColors.primary,
      titleParts: [
        TextPart('Pesan,', false),
        TextPart(' Ambil,', false),
        TextPart(' Sikat', true),
        TextPart('!', false),
      ],
      description:
          'Pesan di aplikasi, tunjukin kodenya ke kasir, dan bawa pulang makananmu sendiri. Gampang, cepat, sikat!',
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;
  bool _isLoading = false;

  double? get _progress {
    if (_isLoading) return null;
    if (_isFinishing) return 1.0;
    return _currentPage / _pages.length;
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  Future<void> _finishOnboarding() async {
    if (_isLoading || _isFinishing) return;

    setState(() => _isFinishing = true);
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isFinishing = false;
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.go(AppRoutes.login);
  }

  void _onSkip() {
    if (_isLoading || _isFinishing) return;
    _finishOnboarding();
  }

  void _onNext() {
    if (_isLoading || _isFinishing) return;

    if (!_isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: page.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isShort = constraints.maxHeight < AppLayout.shortPhoneHeight;
            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xl,
                      right: AppSpacing.xxl,
                    ),
                    child: HapHapSkipButton(
                      onPressed: _onSkip,
                      isWhiteVariant: page.backgroundColor == AppColors.primary,
                    ),
                  ),
                ),

                Expanded(
                  flex: isShort ? 1 : 3,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.sm,
                        ),
                        child: Image.asset(
                          _pages[index].imagePath,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),

                Expanded(
                  flex: isShort ? 5 : 4,
                  child: Container(
                    key: const Key('onboarding_bottom_panel'),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.sheetTop,
                    ),
                    child: SafeArea(
                      top: false,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.xxl,
                          AppSpacing.xxl,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                children: page.titleParts.map((part) {
                                  return TextSpan(
                                    text: part.text,
                                    style: AppTextStyle(
                                      fontSize: AppTypography.headlineSmall,
                                      fontWeight: FontWeight.bold,
                                      color: part.isHighlighted
                                          ? AppColors.primary
                                          : AppColors.black,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            Text(
                              page.description,
                              textAlign: TextAlign.left,
                              style: const AppTextStyle(
                                fontSize: AppTypography.bodyLarge,
                                color: AppColors.greyLight,
                                height: AppTypography.lineHeightLoose,
                              ),
                            ),

                            SizedBox(
                              height: isShort ? AppSpacing.lg : AppSpacing.xxl,
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                top: isShort ? AppSpacing.lg : AppSpacing.xxl,
                                bottom: isShort
                                    ? AppSpacing.lg
                                    : AppSpacing.xxl,
                              ),
                              child: Center(
                                child: HapHapOnboardingNextButton(
                                  progress: _progress,
                                  size: AppSizes.mediaLarge,
                                  onPressed: _onNext,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class OnboardingData {
  final String imagePath;
  final Color backgroundColor;
  final List<TextPart> titleParts;
  final String description;

  const OnboardingData({
    required this.imagePath,
    required this.backgroundColor,
    required this.titleParts,
    required this.description,
  });
}

class TextPart {
  final String text;
  final bool isHighlighted;

  const TextPart(this.text, this.isHighlighted);
}
