class User {
  final String uid;
  final String email;
  final String name;
  final String surname;
  final String dateOfBirth;
  final String maritalStatus;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.uid,
    required this.email,
    required this.name,
    required this.surname,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
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
      maritalStatus: json['maritalStatus'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
    );
  }

  factory User.empty() => const User(
    uid: '',
    email: '',
    name: '',
    surname: '',
    dateOfBirth: '',
    maritalStatus: '',
    emailVerified: false,
    createdAt: null,
    updatedAt: null,
  );

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'surname': surname,
      'dateOfBirth': dateOfBirth,
      'maritalStatus': maritalStatus,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? name,
    String? surname,
    String? dateOfBirth,
    String? maritalStatus,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isEmpty() => this == User.empty();
}
