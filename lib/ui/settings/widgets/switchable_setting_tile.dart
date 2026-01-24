import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:huzur_islamda/app/app.dart';

class SwitchableSettingTile extends StatelessWidget {
  const SwitchableSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.valueListenable,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ValueListenable<bool> valueListenable;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<bool>(
      valueListenable: valueListenable,
      builder: (context, value, _) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: context.isSmallScreen ? 10 : 12,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: context.isSmallScreen ? 20 : 22),
              ),
              SizedBox(width: context.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: context.responsiveFontSize(
                          textTheme.bodyLarge?.fontSize,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.6),
                        fontSize: context.responsiveFontSize(
                          textTheme.bodyMedium?.fontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        );
      },
    );
  }
}
