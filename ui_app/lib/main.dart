import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:konnect/screens/schedule/schedule_screen.dart';
import 'package:konnect/screens/trend/trend_screen.dart';
import 'package:provider/provider.dart';
import 'package:konnect/providers/platform_provider.dart';
import 'package:konnect/providers/subscription_provider.dart';

import 'models/social_account.dart';
import 'models/social_profile.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/authentication/signup_screen.dart';
import 'screens/authentication/otp_screen.dart';
import 'screens/authentication/forgot_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ai/ai_entry.dart';
import 'screens/ai/ai_chat_screen.dart';
import 'screens/ai/screens/conversation_list_screen.dart';
import 'screens/ai/providers/chat_provider.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/account_switcher_screen.dart';
import 'screens/profile/social_profiles_screen.dart';
import 'screens/launcher_screen.dart';
import 'screens/authentication/reset_pass_screen.dart';
import 'screens/social/instagram_auth_view.dart';

import 'screens/social/instagram_profile_screen.dart';
import 'screens/social/facebook_profile_screen.dart';
import 'screens/social/linkedin_profile_screen.dart';
import 'screens/social/twitter_profile_screen.dart';

import 'screens/post/post_screen.dart';
import 'screens/post/instagram_post_screen.dart';
import 'screens/post/facebook_post_screen.dart';
import 'screens/post/twitter_post_screen.dart';
import 'screens/post/linkedin_post_screen.dart';

import 'screens/analytics/analytics_screen.dart';
import 'screens/subscription/subscription_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final platformProvider = PlatformProvider();
  await platformProvider.initialize();
  
  runApp(MyApp(platformProvider: platformProvider));
}

class MyApp extends StatelessWidget {
  final PlatformProvider platformProvider;

  const MyApp({super.key, required this.platformProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: platformProvider),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Konnect',
        theme: ThemeData(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
        ),
        home: const LauncherScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/forgot': (context) => const ForgotScreen(),
          '/reset_pass': (context) => const ResetPasswordScreen(),
          '/otp': (context) => const OtpScreen(),
          '/home': (context) => const HomeScreen(),
          '/ai_bot': (context) => const AIEntry(),
          '/ai_chat': (context) => const AIChatScreen(),
          '/ai_conversations': (context) => const ConversationListScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/account-switcher': (context) => const AccountSwitcherScreen(),
          '/social-profiles': (context) => const SocialProfilesScreen(),
          '/login-instagram': (context) => InstagramOAuthPage(),
          '/instagram': (context) => const InstagramProfileScreen(),
          '/x': (context) => const TwitterProfileScreen(),
          '/linkedin': (context) => const LinkedInProfileScreen(),
          '/facebook': (context) => const FacebookProfileScreen(),
          '/post': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            DateTime? preSelectedDate;
            String? platform;
            List<String>? platforms;
            
            if (args is Map) {
              preSelectedDate = args['date'] as DateTime?;
              platform = args['platform'] as String?;
              platforms = args['platforms'] as List<String>?;
            } else if (args is DateTime) {
              preSelectedDate = args;
            }

            if (platforms != null && platforms.isNotEmpty) {
              return PostScreen(preSelectedDate: preSelectedDate, preSelectedPlatforms: platforms);
            }

            switch (platform) {
              case 'IG':
                return InstagramPostScreen(preSelectedDate: preSelectedDate);
              case 'FB':
                return FacebookPostScreen(preSelectedDate: preSelectedDate);
              case 'X':
                return TwitterPostScreen(preSelectedDate: preSelectedDate);
              case 'LN':
                return LinkedInPostScreen(preSelectedDate: preSelectedDate);
              default:
                return PostScreen(preSelectedDate: preSelectedDate);
            }
          },
          '/schedule': (context) => const ScheduleScreen(),
          '/trend': (context) => const TrendScreen(),
          '/analytics': (context) => const AnaScreen(),
          '/subscription': (context) => const SubscriptionScreen(),
        },
      ),
    );
  }
}