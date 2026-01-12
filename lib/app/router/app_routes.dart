/// Route path constants for the application.
///
/// All route paths are defined here to maintain consistency
/// and avoid magic strings throughout the codebase.
class AppRoutes {
  // Prevent instantiation
  const AppRoutes._();

  // -------------------- PUBLIC ROUTES --------------------

  /// Onboarding screen route
  static const String onboarding = '/';

  /// Sign in screen route
  static const String signIn = '/sign_in';

  /// Sign up screen route
  static const String signUp = '/sign_up';

  /// Email verification screen route
  static const String emailVerification = '/email_verification';

  // -------------------- MAIN APP ROUTES --------------------

  /// Flow (home) screen route
  static const String flow = '/flow';

  /// Search screen route
  static const String search = '/search';

  /// Prayer screen route
  static const String prayer = '/prayer';

  /// Dhikr screen route
  static const String dhikr = '/dhikr';

  /// Profile screen route
  static const String profile = '/profile';

  // -------------------- USER ROUTES --------------------

  /// User initialization screen route
  static const String userInitialize = '/user_initialize';

  /// Create profile screen route
  static const String createProfile = '/create_profile';

  /// Edit profile screen route
  static const String editProfile = '/profile/edit_profile';

  // -------------------- OTHER ROUTES --------------------

  /// Settings screen route
  static const String settings = '/settings';

  /// Post detail screen route
  static const String postDetail = '/post_detail';

  /// Create dhikr screen route
  static const String createDhikr = '/dhikr/create_dhikr';

  /// Dhikr detail screen route
  static const String dhikrDetail = '/dhikr/dhikr_detail';
}
