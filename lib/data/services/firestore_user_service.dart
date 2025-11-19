import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users';

  /// Kullanıcıyı Firestore'a kaydet
  Future<Result<void>> createUser({
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
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_collectionName).doc(uid).set(userData);

      return Result.ok(null);
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
  Future<Result<void>> updateUser({
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

      return Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to update user: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to update user: $e'));
    }
  }

  /// Kullanıcı bilgilerini Firestore'dan getir
  Future<Result<Consumer>> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(uid).get();

      if (!doc.exists) {
        return Result.error(Exception('User not found'));
      }

      final data = doc.data()!;
      final consumer = Consumer(
        uid: data['uid'] as String,
        email: data['email'] as String,
        name: data['name'] as String?,
        surname: data['surname'] as String?,
        dateOfBirth: data['dateOfBirth'] as String?,
        maritalStatus: data['maritalStatus'] as String?,
        emailVerified: data['emailVerified'] as bool? ?? false,
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : null,
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] as Timestamp).toDate()
            : null,
      );

      return Result.ok(consumer);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to get user: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to get user: $e'));
    }
  }

  /// Kullanıcıyı Firestore'dan sil
  Future<Result<void>> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collectionName).doc(uid).delete();
      return Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to delete user: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to delete user: $e'));
    }
  }
}
