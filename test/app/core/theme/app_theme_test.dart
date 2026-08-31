import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/core/constants/app_colors.dart';
import 'package:huzur_islamda/app/core/theme/app_theme.dart';

void main() {
  group('AppTheme.lightTheme', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.lightTheme;
    });

    test('is a light Material 3 theme', () {
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    test('color scheme uses the AppColors palette', () {
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.colorScheme.surface, AppColors.surface);
    });

    test('primaryColor matches the color scheme primary', () {
      // ThemeData derives primaryColor from colorScheme.primary when a
      // colorScheme is provided.
      expect(theme.primaryColor, AppColors.primary);
    });

    test('scaffold and app bar use the AppColors background', () {
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.appBarTheme.backgroundColor, AppColors.background);
      expect(theme.appBarTheme.centerTitle, isTrue);
      expect(theme.appBarTheme.elevation, 0);
    });

    test('divider color is grey.shade400', () {
      expect(theme.dividerColor, Colors.grey.shade400);
    });

    test('input decoration borders are rounded with the primary focus color', () {
      final decoration = theme.inputDecorationTheme;
      expect(decoration.labelStyle?.color, Colors.grey);

      final enabled = decoration.enabledBorder;
      expect(enabled, isA<OutlineInputBorder>());
      expect((enabled! as OutlineInputBorder).borderRadius, BorderRadius.circular(15));
      expect(enabled.borderSide.color, Colors.grey);

      final focused = decoration.focusedBorder;
      expect(focused, isA<OutlineInputBorder>());
      expect((focused! as OutlineInputBorder).borderRadius, BorderRadius.circular(15));
      expect(focused.borderSide.color, AppColors.primary);
      expect(focused.borderSide.width, 1.5);
    });

    test('elevated buttons are flat, primary and white-on-primary', () {
      final style = theme.elevatedButtonTheme.style;
      expect(style, isNotNull);
      expect(style!.backgroundColor?.resolve({}), AppColors.primary);
      expect(style.foregroundColor?.resolve({}), Colors.white);
      expect(style.elevation?.resolve({}), 0);

      final shape = style.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());
      expect(
        (shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(15),
      );
    });

    test('text buttons use grey[700] foreground', () {
      final style = theme.textButtonTheme.style;
      expect(style, isNotNull);
      expect(style!.foregroundColor?.resolve({}), Colors.grey[700]);
    });

    test('returns an equivalent theme on every access', () {
      final other = AppTheme.lightTheme;
      expect(other.colorScheme, theme.colorScheme);
      expect(other.scaffoldBackgroundColor, theme.scaffoldBackgroundColor);
      expect(other.useMaterial3, theme.useMaterial3);
    });
  });
}
