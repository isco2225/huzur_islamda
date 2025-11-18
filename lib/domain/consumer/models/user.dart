class Consumer {
  final String uid;
  final String email;
  final String? name;
  final String? surname;
  final String? dateOfBirth;
  final String? maritalStatus;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Consumer({
    required this.uid,
    required this.email,
    this.name,
    this.surname,
    this.dateOfBirth,
    this.maritalStatus,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

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

  factory Consumer.fromJson(Map<String, dynamic> json) {
    return Consumer(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Consumer copyWith({
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
    return Consumer(
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
}
