import 'package:flutter/material.dart';

enum Permission {
  location,
  notification;

  String toUserFriendlyName(BuildContext context) {
    return switch (this) {
      Permission.location => 'Konum',
      Permission.notification => 'Bildirim',
    };
  }

  String toUserFriendlyReason(BuildContext context) {
    return switch (this) {
      Permission.location => 'Konum izinleri gereklidir.',
      Permission.notification => 'Bildirim izinleri gereklidir.',
    };
  }

  String toUserFriendlyRequired(BuildContext context) {
    return switch (this) {
      Permission.location => 'Konum izinleri gereklidir.',
      Permission.notification => 'Bildirim izinleri gereklidir.',
    };
  }
}
