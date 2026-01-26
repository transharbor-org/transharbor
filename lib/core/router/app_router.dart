import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/personals/screens/personals_feed_screen.dart';
import '../../features/personals/screens/create_personal_screen.dart';
import '../../features/messaging/screens/messages_list_screen.dart';
import '../../features/messaging/screens/conversation_screen.dart';
import '../../features/governance/screens/governance_screen.dart';
import '../../features/governance/screens/voting_screen.dart';
import '../../features/groups/screens/groups_list_screen.dart';
import '../../features/groups/screens/group_detail_screen.dart';
import '../../features/groups/screens/create_group_screen.dart';
import '../../features/moderation/screens/moderation_screen.dart';
import '../../features/admin/screens/admin_management_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../services/logging_service.dart';

/// Navigation observer for logging route changes
class NavigationLogger extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      logger.setScreen(route.settings.name);
      logger.info('Navigation: Pushed to ${route.settings.name}', metadata: {
        'from': previousRoute?.settings.name,
        'to': route.settings.name,
      });
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      logger.setScreen(previousRoute!.settings.name);
      logger.info('Navigation: Popped to ${previousRoute.settings.name}',
          metadata: {
            'from': route.settings.name,
            'to': previousRoute.settings.name,
          });
    }
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    observers: [NavigationLogger()],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/personals',
        builder: (context, state) => const PersonalsFeedScreen(),
      ),
      GoRoute(
        path: '/personals/create',
        builder: (context, state) => const CreatePersonalScreen(),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesListScreen(),
      ),
      GoRoute(
        path: '/messages/:conversationId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ConversationScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: '/governance',
        builder: (context, state) => const GovernanceScreen(),
      ),
      GoRoute(
        path: '/governance/vote/:proposalId',
        builder: (context, state) {
          final proposalId = state.pathParameters['proposalId']!;
          return VotingScreen(proposalId: proposalId);
        },
      ),
      GoRoute(
        path: '/groups',
        builder: (context, state) => const GroupsListScreen(),
      ),
      GoRoute(
        path: '/groups/create',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/groups/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupDetailScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/moderation',
        builder: (context, state) => const ModerationScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminManagementScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
