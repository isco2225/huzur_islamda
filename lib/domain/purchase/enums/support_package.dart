enum SupportPackage {
  kehribar,
  inci,
  elmas;

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
      case SupportPackage.kehribar:
        return 'kehribar';
      case SupportPackage.inci:
        return 'inci';
      case SupportPackage.elmas:
        return 'elmas';
    }
  }
}
