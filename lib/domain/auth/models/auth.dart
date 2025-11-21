class Auth {
  final String uid;
  final String email;

  const Auth({required this.uid, required this.email});

  factory Auth.fromJson(Map<String, Object?> json) {
    return Auth(uid: json['uid'] as String, email: json['email'] as String);
  }

  factory Auth.empty() => const Auth(uid: '', email: '');

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email};
  }

  bool isSignedIn() => this != Auth.empty();
}
