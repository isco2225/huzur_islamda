class AppPreferences {
  const AppPreferences({
    required this.isVibrationEnabled,
    required this.isNotificationsEnabled,
    required this.isOnboardingCompleted,
    required this.assistantDailyLimit,
  });
  final bool isVibrationEnabled;
  final bool isNotificationsEnabled;
  final bool isOnboardingCompleted;
  final int assistantDailyLimit;

  factory AppPreferences.empty() => const AppPreferences(
    isVibrationEnabled: true,
    isNotificationsEnabled: false,
    isOnboardingCompleted: false,
    assistantDailyLimit: 10,
  );

  factory AppPreferences.fromJson(Map<String, Object?> json) {
    return AppPreferences(
      isVibrationEnabled: json['isVibrationEnabled'] as bool? ?? true,
      isNotificationsEnabled: json['isNotificationsEnabled'] as bool? ?? false,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
      assistantDailyLimit: json['assistantDailyLimit'] as int? ?? 10,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'isVibrationEnabled': isVibrationEnabled,
      'isNotificationsEnabled': isNotificationsEnabled,
      'isOnboardingCompleted': isOnboardingCompleted,
      'assistantDailyLimit': assistantDailyLimit,
    };
  }

  AppPreferences copyWith({
    bool? isVibrationEnabled,
    bool? isNotificationsEnabled,
    bool? isOnboardingCompleted,
    int? assistantDailyLimit,
  }) {
    return AppPreferences(
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      assistantDailyLimit: assistantDailyLimit ?? this.assistantDailyLimit,
    );
  }

  bool isEmpty() => this == AppPreferences.empty();
}
