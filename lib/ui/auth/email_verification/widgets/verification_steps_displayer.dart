import 'package:flutter/material.dart';

class VerificationStepsDisplayer extends StatelessWidget {
  const VerificationStepsDisplayer({
    super.key,
    required this.stepNumber,
    required this.text,
  });
  final int stepNumber;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF5EB),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber.toString(),
            style: const TextStyle(
              color: Color(0xFF6B8E4E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }
}
