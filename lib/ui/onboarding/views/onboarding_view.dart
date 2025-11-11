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
      const SignInRoute().go(context);
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
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [OnboardingViewFirst(), OnboardingViewSecound()],
          ),
          Positioned(
            bottom: 90,
            right: 0,
            left: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 330,
                  height: 50,
                  child: AppButton(
                    running: _isLoading,
                    onPressed: _handleButtonPress,
                    text: _currentPage == 0
                        ? AppStrings.onboardingNext
                        : AppStrings.start,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PageIndicator(controller: _controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
