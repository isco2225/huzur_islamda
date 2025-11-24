import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users';

  /// Kullanıcıyı Firestore'a kaydet
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String maritalStatus,
  }) async {
    try {
      final userData = {
        'uid': uid,
        'email': email,
        'name': name,
        'surname': surname,
        'dateOfBirth': dateOfBirth,
        'maritalStatus': maritalStatus,
        'emailVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isRegistered': true,
      };

      await _firestore.collection(_collectionName).doc(uid).set(userData);

      // Firestore'dan gerçek timestamp değerlerini almak için dokümanı tekrar oku
      final doc = await _firestore.collection(_collectionName).doc(uid).get();
      final data = doc.data()!;
      // Timestamp'leri DateTime'a dönüştür (domain layer için temiz veri)
      final cleanData = _convertTimestampsToDateTime(data);
      final user = User.fromJson(cleanData);

      return Result.ok(user);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to create user: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to create user: $e'));
    }
  }

  /// Kullanıcının email doğrulama durumunu güncelle
  Future<Result<void>> updateEmailVerificationStatus({
    required String uid,
    required bool emailVerified,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(uid).update({
        'emailVerified': emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception(
          'Failed to update email verification status: ${e.message ?? e.code}',
        ),
      );
    } catch (e) {
      return Result.error(
        Exception('Failed to update email verification status: $e'),
      );
    }
  }

  /// Kullanıcı bilgilerini güncelle
  Future<Result<User>> updateUser({
    required String uid,
    String? name,
    String? surname,
    String? dateOfBirth,
    String? maritalStatus,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (surname != null) updateData['surname'] = surname;
      if (dateOfBirth != null) updateData['dateOfBirth'] = dateOfBirth;
      if (maritalStatus != null) updateData['maritalStatus'] = maritalStatus;

      await _firestore.collection(_collectionName).doc(uid).update(updateData);
      final doc = await _firestore.collection(_collectionName).doc(uid).get();
      final data = doc.data()!;
      // Timestamp'leri DateTime'a dönüştür (domain layer için temiz veri)
      final cleanData = _convertTimestampsToDateTime(data);
      final user = User.fromJson(cleanData);
      return Result.ok(user);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to update user: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to update user: $e'));
    }
  }

  /// Kullanıcı bilgilerini Firestore'dan getir
  Future<Result<User?>> readAuthenticatedUser({required String uid}) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(uid).get();
      if (!doc.exists) {
        print('User not found on firestore');
        return Result.ok(null);
      }
      final data = doc.data()!;
      // Timestamp'leri DateTime'a dönüştür (domain layer için temiz veri)
      final cleanData = _convertTimestampsToDateTime(data);
      final user = User.fromJson(cleanData);

      return Result.ok(user);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to get user: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to get user: $e'));
    }
  }

  /// Kullanıcıyı Firestore'dan sil
  Future<Result<void>> deleteAuthenticatedUser({required String uid}) async {
    try {
      await _firestore.collection(_collectionName).doc(uid).delete();
      return Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception(
          'Failed to delete authenticated user: ${e.message ?? e.code}',
        ),
      );
    } catch (e) {
      return Result.error(Exception('Failed to delete authenticated user: $e'));
    }
  }

  /// Firestore'dan gelen Timestamp'leri DateTime'a dönüştürür
  Map<String, dynamic> _convertTimestampsToDateTime(Map<String, dynamic> data) {
    final cleanData = Map<String, dynamic>.from(data);

    if (cleanData['createdAt'] is Timestamp) {
      cleanData['createdAt'] = (cleanData['createdAt'] as Timestamp)
          .toDate()
          .toIso8601String();
    }

    if (cleanData['updatedAt'] is Timestamp) {
      cleanData['updatedAt'] = (cleanData['updatedAt'] as Timestamp)
          .toDate()
          .toIso8601String();
    }

    return cleanData;
  }

  // Future<Result<User?>> initUser({required String uid}) async {
  //   try {
  //     final doc = await _firestore.collection(_collectionName).doc(uid).get();
  //     if (!doc.exists) {
  //       return Result.ok(null);
  //     }
  //     final data = doc.data()!;
  //     final cleanData = _convertTimestampsToDateTime(data);
  //     final user = User.fromJson(cleanData);
  //     return Result.ok(user);
  //   } on FirebaseException catch (e) {
  //     return Result.error(
  //       Exception('Failed to init user: ${e.message ?? e.code}'),
  //     );
  //   } catch (e) {
  //     return Result.error(Exception('Failed to init user: $e'));
  //   }
  // }
}
