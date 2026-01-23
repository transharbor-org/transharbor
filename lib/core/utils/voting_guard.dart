import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../models/membership_type.dart';

/// Utilities for voting eligibility checks
class VotingGuard {
  /// Check if current user can vote
  static bool canVote(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.canVote ?? false;
  }

  /// Check if current user is a full member
  static bool isFullMember(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.isFullMember ?? false;
  }

  /// Get current user's membership type
  static MembershipType? getMembershipType(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.membershipType;
  }

  /// Check if current user has specific membership type
  static bool hasMembershipType(BuildContext context, MembershipType type) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.membershipType == type;
  }
}

/// Widget that only shows content if user can vote
class VotingMemberOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const VotingMemberOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.currentUser?.canVote ?? false) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Widget that shows different content based on membership type
class MembershipBasedWidget extends StatelessWidget {
  final Widget? votingMemberWidget;
  final Widget? nonVotingWidget;
  final Widget? fallback;

  const MembershipBasedWidget({
    super.key,
    this.votingMemberWidget,
    this.nonVotingWidget,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final membershipType = auth.currentUser?.membershipType;
        
        switch (membershipType) {
          case MembershipType.votingMember:
            return votingMemberWidget ?? nonVotingWidget ?? fallback ?? const SizedBox.shrink();
          case MembershipType.nonVoting:
            return nonVotingWidget ?? fallback ?? const SizedBox.shrink();
          default:
            return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}

/// Banner to show non-voting members why they can't vote
class NonVotingMemberBanner extends StatelessWidget {
  final String? customMessage;

  const NonVotingMemberBanner({
    super.key,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.currentUser?.canVote ?? true) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customMessage ?? 
                  'You are a non-voting member. Full voting privileges are required to participate in governance decisions.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
