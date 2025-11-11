import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
    return BaseScaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleText(title: 'Hemen Giriş Yap'),
            SubtitleText(text: 'Bu eşsiz deneyim için heasp bilgilerini gir'),
            EmailTextField(),
            PasswordTextField(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: AppButton(
                  onPressed: () {},
                  text: 'Giriş Yap',
                  running: loading,
                ),
              ),
            ),
            OrDivider(),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('Google ile giriş yap'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('GApple ile giriş yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.text = 'veya'});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: TextStyle(color: Colors.grey.shade800)),
        ),
        const Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }
}
