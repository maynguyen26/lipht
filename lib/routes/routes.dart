class Routes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String main = '/main';
  static const String home = '/home';

  // Workout routes
  static const String build = '/build';
  static const String buildProgram = '/build/program';
  static const String chooseProgram = '/build/choose';
  static const String emptySession = '/build/empty';

  // Nutrition routes
  static const String fuel = '/fuel';
  static const String mealAnalysis = '/fuel/analysis';
  static const String foodDetails = '/fuel/food-details';

  // Sleep routes
  static const String sleep = '/sleep';
  static const String sleepStats = '/sleep/stats';
  static const String addSleep = '/sleep/add';

  // Social routes
  static const String friends = '/friends';
  static const String friendSearch = '/friends/search';
  static const String friendProfile = '/friends/profile';

  // Settings routes
  static const String settings = '/settings';
  static const String accountSettings = '/settings/account';
  static const String privacySettings = '/settings/privacy';
  static const String blockList = '/settings/block-list';
}
