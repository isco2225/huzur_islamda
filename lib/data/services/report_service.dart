import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'reports';

  Future<Result<void>> reportPost({
    required String reporterId,
    required String reportedPostId,
    required String reason,
  }) async {
    try {
      final reportData = {
        'reporterId': reporterId,
        'reportedPostId': reportedPostId,
        'reason': reason,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _firestore
          .collection(_collectionName)
          .doc(reportedPostId + reporterId)
          .set(reportData);
      return Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to report post: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to report post: $e'));
    }
  }
}
