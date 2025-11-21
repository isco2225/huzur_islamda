// import '../../../app/app.dart';
// import '../../../data/repositories/auth/auth_repository.dart';
// import '../../../data/repositories/user/user_repository.dart';
// import '../models/models.dart';

// class SignUpUseCase {
//   SignUpUseCase({
//     required AuthRepository authRepository,
//     required UserRepository userRepository,
//   }) : _authRepository = authRepository,
//        _userRepository = userRepository;

//   final AuthRepository _authRepository;
//   final UserRepository _userRepository;

//   Future<Result<User>> execute({
//     required String email,
//     required String password,
//     required String name,
//     required String surname,
//     required String dateOfBirth,
//     required String maritalStatus,
//   }) async {
//     // 1. Firebase Auth'da kullanıcı oluştur (email doğrulama otomatik gönderilir)
//     final authResult = await _authRepository.requestSignUp(
//       email: email,
//       password: password,
//       name: name,
//       surname: surname,
//       dateOfBirth: dateOfBirth,
//       maritalStatus: maritalStatus,
//     );

//     switch (authResult) {
//       case Ok():
//         final auth = authResult.asOk.value;

//         // 2. Kullanıcıyı Firestore'a kaydet (emailVerified: false olarak)
//         final firestoreResult = await _userRepository.createUser(
//           uid: auth.uid,
//           email: auth.email,
//           name: name,
//           surname: surname,
//           dateOfBirth: dateOfBirth,
//           maritalStatus: maritalStatus,
//         );

//         switch (firestoreResult) {
//           case Ok():
//             // Başarılı - Firestore'dan dönen User objesini döndür
//             return Result.ok(firestoreResult.asOk.value);
//           case Error():
//             // Firestore'a kaydetme başarısız oldu
//             // Ama kullanıcı Firebase Auth'da oluşturuldu
//             return Result.error(
//               Exception(
//                 'Kullanıcı oluşturuldu ancak bilgiler kaydedilemedi: ${firestoreResult.asError.error}',
//               ),
//             );
//         }
//       case Error():
//         return Result.error(authResult.asError.error);
//     }
//   }
// }
