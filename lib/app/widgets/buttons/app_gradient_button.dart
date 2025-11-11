import 'package:flutter/material.dart';

class AppGradientButton extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isBordered;
  final bool isDestructive;
  final bool isLoading;

  const AppGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onLongPress,
    this.textStyle,
    this.borderRadius,
    this.width = 320.0,
    this.height = 44.0,
    this.isDestructive = false,
    this.gradient = const LinearGradient(
      colors: [
        Color(0xffda7eaf),
        Color(0xff9E85EA),
      ],
    ),
    this.isBordered = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(8);
    final destructiveGradient = LinearGradient(colors: [
      Theme.of(context).colorScheme.errorContainer,
      Theme.of(context).colorScheme.errorContainer,
    ]);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isDestructive
            ? destructiveGradient
            : isBordered
                ? null
                : gradient,
        borderRadius: borderRadius,
        border: isBordered && !isDestructive
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
      ),
      child: ElevatedButton(
        onPressed: !isLoading ? onPressed : null,
        onLongPress: !isLoading ? onLongPress : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: !isLoading
            ? Text(
                text,
                textAlign: TextAlign.center,
                style: textStyle ??
                    TextStyle(
                      color: isBordered
                          ? null
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
      ),
    );
  }
}
