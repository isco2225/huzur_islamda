class AppPreferences {
  const AppPreferences({
    required this.isVibrationEnabled,
    required this.isNotificationsEnabled,
    required this.isOnboardingCompleted,
    required this.assistantDailyLimit,
    required this.lastLimitResetDate,
  });
  final bool isVibrationEnabled;
  final bool isNotificationsEnabled;
  final bool isOnboardingCompleted;
  final int assistantDailyLimit;
  final String lastLimitResetDate;

  factory AppPreferences.empty() {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return AppPreferences(
      isVibrationEnabled: true,
      isNotificationsEnabled: false,
      isOnboardingCompleted: false,
      assistantDailyLimit: 10,
      lastLimitResetDate: today,
    );
  }

  factory AppPreferences.fromJson(Map<String, Object?> json) {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return AppPreferences(
      isVibrationEnabled: json['isVibrationEnabled'] as bool? ?? true,
      isNotificationsEnabled: json['isNotificationsEnabled'] as bool? ?? false,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
      assistantDailyLimit: json['assistantDailyLimit'] as int? ?? 10,
      lastLimitResetDate: json['lastLimitResetDate'] as String? ?? today,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVibrationEnabled': isVibrationEnabled,
      'isNotificationsEnabled': isNotificationsEnabled,
      'isOnboardingCompleted': isOnboardingCompleted,
      'assistantDailyLimit': assistantDailyLimit,
      'lastLimitResetDate': lastLimitResetDate,
    };
  }

  AppPreferences copyWith({
    bool? isVibrationEnabled,
    bool? isNotificationsEnabled,
    bool? isOnboardingCompleted,
    int? assistantDailyLimit,
    String? lastLimitResetDate,
  }) {
    return AppPreferences(
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      assistantDailyLimit: assistantDailyLimit ?? this.assistantDailyLimit,
      lastLimitResetDate: lastLimitResetDate ?? this.lastLimitResetDate,
    );
  }

  bool isEmpty() => this == AppPreferences.empty();
}
