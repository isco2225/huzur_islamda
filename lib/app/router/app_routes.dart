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

  /// Reset password screen route
  static const String resetPassword = '/reset_password';

  // -------------------- MAIN APP ROUTES --------------------

  /// Flow (home) screen route
  static const String flow = '/flow';

  /// Assistant screen route
  static const String assistant = '/assistant';

  /// Assistant with post screen route
  static const String assistantForPost = '/assistant_for_post';

  /// Prayer screen route
  static const String prayer = '/prayer';

  /// Dhikr screen route
  static const String dhikr = '/dhikr';

  /// Profile screen route
  static const String profile = '/profile';

  // -------------------- USER ROUTES --------------------

  /// Create profile screen route
  static const String createProfile = '/create_profile';

  /// Edit profile screen route
  static const String editProfile = '/profile/edit_profile';

  /// Change password screen route
  static const String changePassword = '/profile/change_password';

  // -------------------- OTHER ROUTES --------------------

  /// Settings screen route
  static const String settings = '/settings';

  /// Purchase / Paywall screen route
  static const String purchase = '/purchase';

  /// Saved posts screen route
  static const String savedPosts = '/saved_posts';

  /// Post detail screen route
  static const String postDetail = '/post_detail';

  /// Create dhikr screen route
  static const String createDhikr = '/dhikr/create_dhikr';

  /// Create dhikr by mood screen route
  static const String createDhikrByMood = '/dhikr/create_dhikr_by_mood';

  /// Dhikr detail screen route
  static const String dhikrDetail = '/dhikr/dhikr_detail';
}
