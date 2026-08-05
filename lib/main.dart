import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/tenant_config.dart';
import 'presentation/views/auth/login_view.dart';

void main() async {
  // Ensuring native engine layout bindings are verified before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Automated Firebase runtime handshake allocation
  await Firebase.initializeApp();
  
  // Bootstrapping application root wrapper scoped inside Riverpod state layer
  runApp(
    const ProviderScope(
      child: TrueHostelApp(),
    ),
  );
}

class TrueHostelApp extends StatelessWidget {
  const TrueHostelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tenant = TenantConfig.fromEnvironment();

    return MaterialApp(
      title: tenant.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      // Directly setting the secure multi-tenant login gate as the application launch entry point
      home: const LoginView(),
    );
  }
}