import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../ui.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  int _currentPage = 0;
  static const int _totalPages = 2;

  void _handleButtonPress() {
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    } else {
      context.goToSignIn();
    }
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BaseScaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: const [OnboardingViewFirst(), OnboardingViewSecound()],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              responsive.horizontalPadding,
              responsive.isSmallScreen ? 6 : 8,
              responsive.horizontalPadding,
              responsive.isSmallScreen ? 12 : 16,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: responsive.isSmallScreen ? 45 : 50,
                  child: AppButton(
                    running: _isLoading,
                    onPressed: _handleButtonPress,
                    text: _currentPage == 0
                        ? AppStrings.onboardingNext
                        : AppStrings.start,
                  ),
                ),
                SizedBox(height: responsive.isSmallScreen ? 6 : 8),
                PageIndicator(controller: _controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
