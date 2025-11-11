import 'package:flutter/material.dart';
import 'package:huzur_islamda/ui/auth/sign_in/views/sign_in_view.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return const SignInView();
  }
}
