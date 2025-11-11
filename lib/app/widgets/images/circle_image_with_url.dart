import 'package:flutter/material.dart';

class CircleImageWithUrl extends StatelessWidget {
  const CircleImageWithUrl({
    required this.imageUrl,
    super.key,
    this.size = 80,
  });
  final double size;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white10,
        ),
        color: Colors.white10,
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(
            imageUrl,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
