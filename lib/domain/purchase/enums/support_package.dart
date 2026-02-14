enum SupportPackage {
  yearly,
  weekly;

  static SupportPackage? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final e in SupportPackage.values) {
      if (e.value == value) return e;
    }
    return null;
  }
}

extension SupportPackageExtension on SupportPackage {
  String get value {
    switch (this) {
      case SupportPackage.yearly:
        return 'yearly';
      case SupportPackage.weekly:
        return 'weekly';
    }
  }
}
