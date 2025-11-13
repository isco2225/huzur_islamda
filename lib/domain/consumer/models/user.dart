import 'package:cloud_firestore/cloud_firestore.dart';

class Consumer {
  final String uid;
  final String name;
  final DateTime dateOfBirth;
  final String maritalStatus;
  final String email;

  Consumer({
    required this.uid,
    required this.name,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'maritalStatus': maritalStatus,
      'email': email,
    };
  }

  factory Consumer.fromJson(Map<String, dynamic> json) {
    return Consumer(
      uid: json['uid'],
      name: json['name'],
      dateOfBirth: json['dateOfBirth'] is Timestamp
          ? (json['dateOfBirth'] as Timestamp).toDate()
          : (json['dateOfBirth'] as DateTime),
      maritalStatus: json['maritalStatus'],
      email: json['email'],
    );
  }
}
