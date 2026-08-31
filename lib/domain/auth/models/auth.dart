class Auth {
  final String uid;
  final String email;
  final bool isEmailVerified;

  const Auth({
    required this.uid,
    required this.email,
    required this.isEmailVerified,
  });

  factory Auth.fromJson(Map<String, Object?> json) {
    return Auth(
      uid: json['uid'] as String,
      email: json['email'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
    );
  }

  factory Auth.empty() =>
      const Auth(uid: '', email: '', isEmailVerified: false);

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'isEmailVerified': isEmailVerified};
  }

  Auth copyWith({String? uid, String? email, bool? isEmailVerified}) {
    return Auth(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  bool isSignedIn() => uid.isNotEmpty;
}
