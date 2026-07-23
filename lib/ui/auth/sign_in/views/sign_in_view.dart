import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key, required this.viewModel});
  final SignInViewModel viewModel;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _displayEmailError = ValueNotifier(false);
  final ValueNotifier<bool> _displayPasswordError = ValueNotifier(false);
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayEmailError.dispose();
    _displayPasswordError.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(responsive.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/moon_mosque.png',
                width: context.screenWidth * 0.4,
                height: context.screenWidth * 0.4,
              ),
              SizedBox(height: responsive.spacingMedium),
              TitleText(title: 'Hemen Giriş Yap'),
              SubtitleText(
                text: 'Bu eşsiz deneyim için hızlıca giriş yapabilirsin.',
              ),
              SizedBox(height: responsive.spacingMedium),

              // Padding(
              //   padding: EdgeInsets.only(top: responsive.spacingSmall),
              //   child: ListenableBuilder(
              //     listenable: Listenable.merge([
              //       _displayEmailError,
              //       _displayPasswordError,
              //     ]),
              //     builder: (context, child) {
              //       return Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           // SignInEmailTextField(
              //           //   email: _emailController,
              //           //   focusNode: _emailFocusNode,
              //           //   displayError: _displayEmailError,
              //           //   onEmailSubmitted: (email) {
              //           //     _emailFocusNode.unfocus();
              //           //     _passwordFocusNode.requestFocus();
              //           //   },
              //           // ),
              //           // SignInPasswordTextField(
              //           //   password: _passwordController,
              //           //   focusNode: _passwordFocusNode,
              //           //   displayError: _displayPasswordError,
              //           //   onPasswordSubmitted: (password) {
              //           //     _passwordFocusNode.unfocus();
              //           //     if (!_isValueObjectsValid()) return;
              //           //     widget.viewModel.signIn.execute((
              //           //       email: _emailController.text.trim(),
              //           //       password: _passwordController.text,
              //           //     ));
              //           //   },
              //           // ),
              //           // Padding(
              //           //   padding: EdgeInsets.only(
              //           //     top: responsive.isSmallScreen ? 4 : 6,
              //           //   ),
              //           //   child: Align(
              //           //     alignment: Alignment.centerRight,
              //           //     child: GestureDetector(
              //           //       onTap: () => context.pushResetPassword(),
              //           //       child: Text(
              //           //         'Şifremi unuttum',
              //           //         style: TextStyle(
              //           //           color: AppColors.primary,
              //           //           fontSize: responsive.responsiveFontSize(14),
              //           //           fontWeight: FontWeight.w500,
              //           //         ),
              //           //       ),
              //           //     ),
              //           //   ),
              //           // ),
              //         ],
              //       );
              //     },
              //   ),
              //),
              // Padding(
              //   padding: EdgeInsets.only(
              //     top: responsive.isSmallScreen ? 40 : 60,
              //   ),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: responsive.isSmallScreen ? 45 : 50,
              //     child: AppButton(
              //       onPressed: () {
              //         if (!_isValueObjectsValid()) return;
              //         widget.viewModel.signIn.execute((
              //           email: _emailController.text.trim(),
              //           password: _passwordController.text,
              //         ));
              //       },
              //       text: 'Giriş Yap',
              //       running: widget.viewModel.signIn.running,
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.all(responsive.spacingSmall),
              //   child: OrDivider(),
              // ),
              SocialLoginButton(
                text: 'Google ile Giriş Yap',
                icon: Icon(Icons.g_mobiledata),
                onPressed: () {
                  widget.viewModel.signInWithGoogle.execute();
                },
              ),
              SizedBox(height: responsive.isSmallScreen ? 8 : 12),
              Platform.isIOS
                  ? SocialLoginButton(
                      text: 'Apple ile Giriş Yap',
                      icon: Icon(Icons.apple),
                      onPressed: () {
                        widget.viewModel.signInWithApple.execute();
                      },
                    )
                  : SizedBox.shrink(),
              // you dont have an account?
              // Padding(
              //   padding: EdgeInsets.only(top: responsive.spacingSmall),
              //   child: const DontHaveAnAccount(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // bool _isValueObjectsValid() {
  //   final isEmailValid = Email.dirty(_emailController.text.trim()).isValid;
  //   final isPasswordValid = Password.dirty(_passwordController.text).isValid;
  //   _displayEmailError.value = !isEmailValid;
  //   _displayPasswordError.value = !isPasswordValid;
  //   return isPasswordValid && isEmailValid;
  // }
}

// class DontHaveAnAccount extends StatelessWidget {
//   const DontHaveAnAccount({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final responsive = context.responsive;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           'Hesabın yok mu?',
//           style: TextStyle(
//             color: Colors.grey.shade800,
//             fontSize: responsive.responsiveFontSize(14),
//           ),
//         ),
//         SizedBox(width: responsive.isSmallScreen ? 3 : 4),
//         GestureDetector(
//           onTap: () {
//             context.pushSignUp();
//           },
//           child: Text(
//             'Kayıt ol',
//             style: TextStyle(
//               color: AppColors.primary,
//               fontWeight: FontWeight.w600,
//               fontSize: responsive.responsiveFontSize(14),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class OrDivider extends StatelessWidget {
//   const OrDivider({super.key, this.text = 'veya'});
//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     final responsive = context.responsive;
//     return Row(
//       children: [
//         const Expanded(child: Divider(color: Colors.grey)),
//         Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: responsive.isSmallScreen ? 8 : 12,
//           ),
//           child: Text(
//             text,
//             style: TextStyle(
//               color: Colors.grey.shade800,
//               fontSize: responsive.responsiveFontSize(14),
//             ),
//           ),
//         ),
//         const Expanded(child: Divider(color: Colors.grey)),
//       ],
//     );
//   }
// }
