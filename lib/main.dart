import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (optional - fallback to defaults if not found)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file doesn't exist, use default values
    Logger.log('No .env file found, using default configuration', tag: 'ENV');
  }
  
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, QuizProvider>(
          create: (context) => QuizProvider(Provider.of<UserProvider>(context, listen: false)),
          update: (context, userProvider, quizProvider) => QuizProvider(userProvider),
        ),
      ],
      child: MaterialApp(
        title: 'CS Quiz App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
