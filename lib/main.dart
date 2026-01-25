import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/personals/providers/personals_provider.dart';
import 'features/messaging/providers/messaging_provider.dart';
import 'features/governance/providers/governance_provider.dart';
import 'features/groups/providers/groups_provider.dart';
import 'features/moderation/providers/moderation_provider.dart';
import 'core/services/pocketbase_service.dart';
import 'core/services/logging_service.dart';

// Testing end-to-end GitOps automation - 2026-01-24
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging service
  logger.initialize();

  // Global error handler for unhandled errors
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.fatal(
      'Unhandled Flutter error',
      error: details.exception,
      stackTrace: details.stack,
      metadata: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );
    
    // Also log to console in debug mode
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Catch errors in async operations
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.fatal(
      'Unhandled async error',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  // Initialize services
  // await initializeServices();

  runApp(const TransHarborApp());
}

class TransHarborApp extends StatelessWidget {
  const TransHarborApp({super.key});

  @override
  Widget build(BuildContext context) {
    final pbService = PocketBaseService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PersonalsProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
        ChangeNotifierProvider(create: (_) => GovernanceProvider()),
        ChangeNotifierProvider(create: (_) => GroupsProvider()),
        ChangeNotifierProvider(create: (_) => ModerationProvider(pbService)),
      ],
      child: MaterialApp.router(
        title: 'TransHarbor',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
