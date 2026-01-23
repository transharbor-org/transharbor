# Membership Types and Voting Eligibility

## Overview

TransHarbor distinguishes between two types of members for governance participation:

- **Non-Voting Members**: Can participate in community discussions but cannot vote
- **Voting Members**: Full members with voting rights on governance matters

This is separate from the role system (user/moderator/admin), which controls system permissions.

## Membership Types

### Non-Voting Member (Default)

New users start as non-voting members. They can:
- Create and manage personals
- Join groups and participate in discussions
- Send and receive messages
- View governance proposals
- Report content
- Use all standard features

But they **cannot**:
- Vote on governance proposals
- Create governance proposals (if restricted to voting members)
- Participate in decision-making votes

### Voting Member (Full Member)

Full members with voting rights. They can:
- Everything non-voting members can do
- **Vote on governance proposals**
- **Create governance proposals**
- Participate fully in community decision-making

## Membership vs Role

These are two independent systems:

| Attribute | Purpose | Values |
|-----------|---------|--------|
| **Role** | System permissions and moderation | user, moderator, admin |
| **Membership Type** | Voting eligibility | non_voting, voting_member |

**Examples:**
- Non-voting moderator: Can moderate content but not vote
- Voting member with user role: Can vote but has no special permissions
- Admin with non-voting: Has all system access but cannot vote (unusual but possible)

## Implementation

### MembershipType Enum

```dart
enum MembershipType {
  nonVoting,      // Default
  votingMember;   // Full membership
  
  bool get canVote => this == MembershipType.votingMember;
  bool get isFullMember => this == MembershipType.votingMember;
}
```

### User Model

```dart
class User {
  final MembershipType membershipType;
  
  bool get canVote => membershipType.canVote;
  bool get isFullMember => membershipType.isFullMember;
}
```

### Voting Guard Utilities

```dart
import 'package:transharbor/core/utils/voting_guard.dart';

// Check if user can vote
if (VotingGuard.canVote(context)) {
  // Show voting UI
}

// Check membership type
if (VotingGuard.isFullMember(context)) {
  // Full member features
}

// Get membership type
MembershipType? type = VotingGuard.getMembershipType(context);
```

### Guard Widgets

#### VotingMemberOnly

Shows content only to voting members:

```dart
VotingMemberOnly(
  child: ElevatedButton(
    onPressed: () => castVote(),
    child: Text('Vote'),
  ),
  fallback: Text('Voting members only'),
)
```

#### MembershipBasedWidget

Shows different content based on membership:

```dart
MembershipBasedWidget(
  votingMemberWidget: VotingInterface(),
  nonVotingWidget: Text('Upgrade to vote'),
  fallback: Text('Not authenticated'),
)
```

#### NonVotingMemberBanner

Shows explanation to non-voting members:

```dart
NonVotingMemberBanner(
  customMessage: 'Become a voting member to participate in this proposal',
)
```

## Admin Management

### Changing Membership Types

Admins can manage membership types in the user management screen:

1. Navigate to `/admin`
2. Find the user
3. Click the menu button (⋮)
4. Select "Change Membership"
5. Choose membership type

```dart
// Programmatically update membership
await pb.collection('users').update(userId, body: {
  'membership_type': 'voting_member',
});
```

### Visual Indicators

- **Voting Members**: Green chip with vote icon
- **Non-Voting Members**: Gray chip with view icon

## PocketBase Schema

Users collection includes `membership_type` field:

```json
{
  "name": "membership_type",
  "type": "select",
  "required": true,
  "options": {
    "maxSelect": 1,
    "values": ["non_voting", "voting_member"]
  }
}
```

Index for efficient queries:
```sql
CREATE INDEX idx_membership_type ON users (membership_type)
```

## Governance Integration

### Governance Screen

The governance screen adapts based on membership:

- **Voting Members**: Full access to voting interface
- **Non-Voting Members**: See banner explaining voting restriction

```dart
Column(
  children: [
    NonVotingMemberBanner(),
    Expanded(
      child: MembershipBasedWidget(
        votingMemberWidget: GovernanceVotingUI(),
        nonVotingWidget: UpgradeToVoteMessage(),
      ),
    ),
  ],
)
```

## Common Patterns

### Vote Button

```dart
VotingMemberOnly(
  child: ElevatedButton.icon(
    icon: Icon(Icons.how_to_vote),
    label: Text('Cast Vote'),
    onPressed: () => showVotingDialog(),
  ),
  fallback: Tooltip(
    message: 'Voting members only',
    child: ElevatedButton.icon(
      icon: Icon(Icons.lock),
      label: Text('Voting Restricted'),
      onPressed: null, // Disabled
    ),
  ),
)
```

### Proposal Creation

```dart
if (VotingGuard.canVote(context)) {
  // Allow proposal creation
  FloatingActionButton(
    onPressed: () => createProposal(),
    child: Icon(Icons.add),
  );
} else {
  // Show upgrade prompt
  FloatingActionButton(
    onPressed: () => showUpgradeDialog(),
    child: Icon(Icons.lock),
  );
}
```

### Navigation Drawer

```dart
ListTile(
  leading: Icon(Icons.gavel),
  title: Text('Governance'),
  trailing: VotingMemberOnly(
    child: Badge(
      label: Text('${activeProposals}'),
      child: Icon(Icons.how_to_vote),
    ),
  ),
  onTap: () => context.go('/governance'),
)
```

## Upgrading Members

### Criteria for Voting Membership

Communities should establish clear criteria for granting voting membership. Common approaches:

1. **Time-Based**: Members after N days/months
2. **Activity-Based**: Members who contribute X posts/comments
3. **Application-Based**: Members who apply and are approved
4. **Automatic**: All verified users
5. **Donation-Based**: Members who donate/pay dues
6. **Invitation-Based**: Invited by existing voting members

### Workflow Example

```dart
// Check eligibility (custom logic)
bool isEligible = await checkVotingEligibility(userId);

if (isEligible) {
  // Upgrade to voting member
  await pb.collection('users').update(userId, body: {
    'membership_type': 'voting_member',
  });
  
  // Notify user
  await sendNotification(
    userId, 
    'You are now a voting member!',
  );
}
```

## Access Rules

PocketBase rules should respect membership types:

```javascript
// Example: Only voting members can create proposals
@request.auth.id != "" && 
@request.auth.membership_type = "voting_member"

// Example: Only voting members can vote
@request.auth.id != "" && 
@request.auth.membership_type = "voting_member" &&
@request.data.proposal_id != ""
```

## Best Practices

1. **Clear Communication**: Explain voting restrictions upfront
2. **Upgrade Path**: Provide clear path to voting membership
3. **Separate Concerns**: Don't mix membership with roles
4. **Visual Cues**: Use badges/icons to indicate membership status
5. **Fair Criteria**: Establish objective upgrade criteria
6. **Audit Trail**: Log membership changes
7. **Regular Review**: Periodically review inactive voting members

## Testing

```dart
testWidgets('VotingMemberOnly shows for voting member', (tester) async {
  final mockAuth = MockAuthProvider();
  when(mockAuth.currentUser).thenReturn(
    User(
      membershipType: MembershipType.votingMember,
      ...
    ),
  );
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authProvider.overrideWith(() => mockAuth)],
      child: VotingMemberOnly(child: Text('Vote Now')),
    ),
  );
  
  expect(find.text('Vote Now'), findsOneWidget);
});

testWidgets('NonVotingMemberBanner shows for non-voting', (tester) async {
  final mockAuth = MockAuthProvider();
  when(mockAuth.currentUser).thenReturn(
    User(
      membershipType: MembershipType.nonVoting,
      ...
    ),
  );
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authProvider.overrideWith(() => mockAuth)],
      child: NonVotingMemberBanner(),
    ),
  );
  
  expect(find.byType(Container), findsOneWidget);
});
```

## Future Enhancements

- [ ] Automatic membership upgrades based on activity
- [ ] Membership expiration/renewal
- [ ] Multiple membership tiers
- [ ] Membership benefits beyond voting
- [ ] Member statistics dashboard
- [ ] Voting power/weight system
- [ ] Delegated voting
- [ ] Membership application workflow

## Related Documentation

- [Roles & Permissions](ROLES_AND_PERMISSIONS.md) - System access control
- [Governance](../lib/features/governance/README.md) - Governance features
- [Admin Management](ROLES_AND_PERMISSIONS.md#admin-management) - User administration

## Support

For membership-related issues:
1. Verify `membership_type` field in users collection
2. Check auth token includes membership_type
3. Review PocketBase access rules for governance collections
4. Test with different membership types
