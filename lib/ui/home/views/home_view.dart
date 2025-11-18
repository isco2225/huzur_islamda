import 'package:flutter/material.dart';
import 'package:huzur_islamda/app/widgets/base/base_scaffold.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(safeArea: true, body: Center(child: Text('Home')));
  }
}
