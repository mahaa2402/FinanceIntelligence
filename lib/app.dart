import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_finance_ai/providers/auth_provider.dart';
import 'package:smart_finance_ai/screens/auth/login_screen.dart';
import 'package:smart_finance_ai/screens/dashboard/dashboard_screen.dart';
import 'package:smart_finance_ai/screens/splash_screen.dart';
import 'package:smart_finance_ai/utils/theme.dart';

class SmartFinanceApp extends StatelessWidget {
  const SmartFinanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFinanceAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show splash screen initially while checking authentication state
          if (authProvider.isInitializing) {
            return const SplashScreen();
          }
          
          // Show dashboard if logged in, otherwise show login screen
          return authProvider.isLoggedIn 
            ? const DashboardScreen() 
            : const LoginScreen();
        },
      ),
    );
  }
}
