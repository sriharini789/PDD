import 'package:flutter/material.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../features/auth/verify_success_screen.dart';

import '../features/profile/screens/create_profile_screen.dart';
import '../features/profile/screens/select_interests_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/paper/screens/upload_paper_screen.dart';
import '../features/paper/screens/uploading_screen.dart';
import '../features/paper/screens/processing_screen.dart';
import '../features/paper/screens/processing_complete_screen.dart';
import '../features/paper/screens/paper_detail_screen.dart';
import '../features/paper/screens/paper_full_screen.dart';
import '../features/paper/screens/chat_paper_screen.dart';

// Module 3
import '../features/search/screens/ask_question_screen.dart';
import '../features/search/screens/ai_answer_screen.dart';
import '../features/search/screens/find_papers_screen.dart';
import '../features/search/screens/search_results_screen.dart';
import '../features/search/screens/advanced_filters_screen.dart';
import '../features/library/screens/my_library_screen.dart';
import '../features/library/screens/library_papers_screen.dart';
import '../features/library/screens/paper_actions_screen.dart';
import '../features/citation/screens/citation_generator_screen.dart';
import '../features/citation/screens/citation_generated_screen.dart';
import '../features/citation/screens/citation_preview_screen.dart';
import '../features/citation/screens/export_options_screen.dart';
import '../features/notes/screens/notes_screen.dart';
import '../features/notes/screens/add_note_screen.dart';
import '../features/library/screens/reading_list_screen.dart';
import '../features/library/screens/favorites_screen.dart';

// Module 4
import '../features/notifications/screens/notifications_screen.dart';
import '../features/notifications/screens/notification_details_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/user_profile_screen.dart';
import '../features/settings/screens/ai_model_config_screen.dart';
import '../features/settings/screens/privacy_settings_screen.dart';
import '../features/support/screens/help_center_screen.dart';
import '../features/support/screens/contact_support_screen.dart';
import '../features/support/screens/feedback_screen.dart';
import '../features/support/screens/about_screen.dart';
import '../features/support/screens/terms_screen.dart';
import '../features/auth/screens/logout_confirmation_screen.dart';
import '../features/auth/screens/goodbye_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String verifySuccess = '/verify-success';
  static const String dashboard = '/dashboard';
  
  static const String createProfile = '/create-profile';
  static const String selectInterests = '/select-interests';
  static const String uploadPaper = '/upload-paper';
  static const String uploading = '/uploading';
  static const String processing = '/processing';
  static const String processingComplete = '/processing-complete';
  static const String paperDetail = '/paper-detail';
  static const String paperFull = '/paper-full';
  static const String chatPaper = '/chat-paper';

  static const String askQuestion = '/ask';
  static const String aiAnswer = '/ask/answer';
  static const String findPapers = '/search';
  static const String searchResults = '/search/results';
  static const String advancedFilters = '/search/filters';
  static const String library = '/library';
  static const String libraryPapers = '/library/papers';
  static const String paperActions = '/library/actions';
  static const String citationGenerator = '/citations/generator';
  static const String citationGenerated = '/citations/generated';
  static const String citationPreview = '/citations/preview';
  static const String exportOptions = '/export';
  static const String notes = '/notes';
  static const String addNote = '/notes/add';
  static const String readingList = '/reading-lists';
  static const String favorites = '/favorites';

  // Module 4 Routes
  static const String notifications = '/notifications';
  static const String notificationDetails = '/notifications/details';
  static const String settings = '/settings';
  static const String userProfile = '/settings/profile';
  static const String aiModelConfig = '/settings/ai-model';
  static const String privacySettings = '/settings/privacy';
  static const String helpCenter = '/support/help';
  static const String contactSupport = '/support/contact';
  static const String feedback = '/support/feedback';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String logoutConfirm = '/logout/confirm';
  static const String goodbye = '/logout/goodbye';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      signup: (context) => const SignupScreen(),
      login: (context) => const LoginScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      verifySuccess: (context) => const VerifySuccessScreen(),
      
      resetPassword: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final token = args?['token'] ?? '';
        return ResetPasswordScreen(token: token);
      },
      verifyEmail: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final token = args?['token'] ?? '';
        final email = args?['email'] ?? '';
        return VerifyEmailScreen(token: token, email: email);
      },
      
      createProfile: (context) => const CreateProfileScreen(),
      selectInterests: (context) => const SelectInterestsScreen(),
      dashboard: (context) => const DashboardScreen(),
      uploadPaper: (context) => const UploadPaperScreen(),
      uploading: (context) => const UploadingScreen(),
      processing: (context) => const ProcessingScreen(),
      processingComplete: (context) => const ProcessingCompleteScreen(),
      paperDetail: (context) => const PaperDetailScreen(),
      paperFull: (context) => const PaperFullScreen(),
      chatPaper: (context) => const ChatPaperScreen(),

      askQuestion: (context) => const AskQuestionScreen(),
      aiAnswer: (context) => const AiAnswerScreen(),
      findPapers: (context) => const FindPapersScreen(),
      searchResults: (context) => const SearchResultsScreen(),
      advancedFilters: (context) => const AdvancedFiltersScreen(),
      library: (context) => const MyLibraryScreen(),
      libraryPapers: (context) => const LibraryPapersScreen(),
      paperActions: (context) => const PaperActionsScreen(),
      citationGenerator: (context) => const CitationGeneratorScreen(),
      citationGenerated: (context) => const CitationGeneratedScreen(),
      citationPreview: (context) => const CitationPreviewScreen(),
      exportOptions: (context) => const ExportOptionsScreen(),
      notes: (context) => const NotesScreen(),
      addNote: (context) => const AddNoteScreen(),
      readingList: (context) => const ReadingListScreen(),
      favorites: (context) => const FavoritesScreen(),

      notifications: (context) => const NotificationsScreen(),
      notificationDetails: (context) => const NotificationDetailsScreen(),
      settings: (context) => const SettingsScreen(),
      userProfile: (context) => const UserProfileScreen(),
      aiModelConfig: (context) => const AiModelConfigScreen(),
      privacySettings: (context) => const PrivacySettingsScreen(),
      helpCenter: (context) => const HelpCenterScreen(),
      contactSupport: (context) => const ContactSupportScreen(),
      feedback: (context) => const FeedbackScreen(),
      about: (context) => const AboutScreen(),
      terms: (context) => const TermsScreen(),
      logoutConfirm: (context) => const LogoutConfirmationScreen(),
      goodbye: (context) => const GoodbyeScreen(),
    };
  }
}
