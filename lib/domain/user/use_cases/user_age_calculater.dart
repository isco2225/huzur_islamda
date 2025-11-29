class UserAgeCalculater {
  UserAgeCalculater({required this.dateOfBirth});
  final DateTime dateOfBirth;

  int calculateAge() {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    final monthDiff = now.month - dateOfBirth.month;
    final dayDiff = now.day - dateOfBirth.day;

    // if the birth date is in the future, subtract 1 from the age
    if (monthDiff < 0 || (monthDiff == 0 && dayDiff < 0)) age--;
    return age;
  }
}
