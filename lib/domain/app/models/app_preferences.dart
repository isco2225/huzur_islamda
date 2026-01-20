class AppPreferences {
  final bool isVibrationEnabled;
  final bool isNotificationsEnabled;
  final bool isOnboardingCompleted;
  const AppPreferences({
    required this.isVibrationEnabled,
    required this.isNotificationsEnabled,
    required this.isOnboardingCompleted,
  });
  factory AppPreferences.empty() => const AppPreferences(
    isVibrationEnabled: false,
    isNotificationsEnabled: false,
    isOnboardingCompleted: false,
  );

  factory AppPreferences.fromJson(Map<String, Object?> json) {
    return AppPreferences(
      isVibrationEnabled: json['isVibrationEnabled'] as bool? ?? false,
      isNotificationsEnabled: json['isNotificationsEnabled'] as bool? ?? false,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'isVibrationEnabled': isVibrationEnabled,
      'isNotificationsEnabled': isNotificationsEnabled,
      'isOnboardingCompleted': isOnboardingCompleted,
    };
  }

  AppPreferences copyWith({
    bool? isVibrationEnabled,
    bool? isNotificationsEnabled,
    bool? isOnboardingCompleted,
  }) {
    return AppPreferences(
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }

  bool isEmpty() => this == AppPreferences.empty();
}
