import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.titleKey,
    required this.descKey,
  });

  final IconData icon;
  final String titleKey;
  final String descKey;
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  static const List<_OnboardingPageData> _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      icon: Icons.two_wheeler_rounded,
      titleKey: 'ob1_title',
      descKey: 'ob1_desc',
    ),
    _OnboardingPageData(
      icon: Icons.insights_rounded,
      titleKey: 'ob2_title',
      descKey: 'ob2_desc',
    ),
    _OnboardingPageData(
      icon: Icons.lock_outline_rounded,
      titleKey: 'ob3_title',
      descKey: 'ob3_desc',
    ),
  ];

  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      Get.find<AuthViewModel>().completeOnboarding();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12, top: 8),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLast ? 0 : 1,
                  child: TextButton(
                    onPressed: isLast
                        ? null
                        : () => Get.find<AuthViewModel>().completeOnboarding(),
                    child: Text('skip'.tr),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) {
                  final _OnboardingPageData page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(
                              color: AppColors.primaryBorder,
                              width: 2,
                            ),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: AppColors.primaryGlow,
                                blurRadius: 50,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 82,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page.titleKey.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.descKey.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(_pages.length, (int i) {
                final bool active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(isLast ? 'get_started'.tr : 'next'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
