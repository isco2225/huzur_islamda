class UserProfileUtils {
  UserProfileUtils._();

  static String getInitials(String name, String surname) {
    final nameInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final surnameInitial = surname.isNotEmpty ? surname[0].toUpperCase() : '';
    return '$nameInitial$surnameInitial';
  }
}
