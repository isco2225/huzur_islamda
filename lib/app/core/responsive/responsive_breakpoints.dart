/// Responsive breakpoint constants
///
/// Defines screen size breakpoints for responsive design
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Small screen breakpoint (phones in portrait)
  /// Below this width is considered small screen
  static const double small = 360;

  /// Medium screen breakpoint (phones in landscape, small tablets)
  /// Between small and medium is considered normal screen
  static const double medium = 600;

  /// Large screen breakpoint (tablets, desktops)
  /// Above this width is considered large screen
  static const double large = 900;

  /// Extra large screen breakpoint (large tablets, desktops)
  static const double extraLarge = 1200;
}
