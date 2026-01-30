import '../../domain.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String surname;
  final String dateOfBirth;
  final String gender;
  //final double? latitude;
  //final double? longitude;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isRegistered;
  final String? country;
  final String? city;
  final String? districtId;
  // support features
  final bool hasSupported;
  final DateTime? lastSupportedAt;
  final SupportPackage? supportPackage;
  const User({
    required this.uid,
    required this.email,
    required this.name,
    required this.surname,
    required this.dateOfBirth,
    required this.gender,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.isRegistered,
    required this.country,
    required this.city,
    required this.districtId,
    required this.hasSupported,
    this.lastSupportedAt,
    this.supportPackage,
  });

  factory User.fromJson(Map<String, Object?> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return DateTime.parse(value);
      }
      if (value is DateTime) {
        return value;
      }
      return null;
    }

    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      gender: json['gender'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
      isRegistered: json['isRegistered'] as bool? ?? false,
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      districtId: json['districtId'] as String? ?? '',
      hasSupported: json['hasSupported'] as bool? ?? false,
      lastSupportedAt: parseDateTime(json['lastSupportedAt']),
      supportPackage: SupportPackage.fromString(
        json['supportPackage'] as String?,
      ),
    );
  }

  factory User.empty() => const User(
    uid: '',
    email: '',
    name: '',
    surname: '',
    dateOfBirth: '',
    gender: '',
    emailVerified: false,
    createdAt: null,
    updatedAt: null,
    isRegistered: false,
    country: '',
    city: '',
    districtId: '',
    hasSupported: false,
    lastSupportedAt: null,
    supportPackage: null,
  );

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'surname': surname,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isRegistered': isRegistered,
      'country': country,
      'city': city,
      'districtId': districtId,
      'hasSupported': hasSupported,
      'lastSupportedAt': lastSupportedAt?.toIso8601String(),
      'supportPackage': supportPackage?.value,
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? name,
    String? surname,
    String? dateOfBirth,
    String? gender,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRegistered,
    String? country,
    String? city,
    String? districtId,
    bool? hasSupported,
    DateTime? lastSupportedAt,
    SupportPackage? supportPackage,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRegistered: isRegistered ?? this.isRegistered,
      country: country ?? this.country,
      city: city ?? this.city,
      districtId: districtId ?? this.districtId,
      hasSupported: hasSupported ?? this.hasSupported,
      lastSupportedAt: lastSupportedAt ?? this.lastSupportedAt,
      supportPackage: supportPackage ?? this.supportPackage,
    );
  }

  bool isEmpty() => this == User.empty();
}
