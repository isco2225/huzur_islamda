class Consumer {
  final String uid;
  final String email;

  Consumer({required this.uid, required this.email});

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email};
  }

  factory Consumer.fromJson(Map<String, dynamic> json) {
    return Consumer(uid: json['uid'], email: json['email']);
  }
}
