import 'package:flutter/material.dart';

class DhikrHistoryDisplayer extends StatelessWidget {
  const DhikrHistoryDisplayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
        Text('Bugün'),
        IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward)),
      ],
    );
  }
}
