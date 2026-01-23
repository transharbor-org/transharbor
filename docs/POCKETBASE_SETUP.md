# PocketBase Collections Schema

This document describes the PocketBase collections needed for the TransHarbor app.

## Collections

### users (auth collection)
- **Type**: Auth Collection
- **Fields**:
  - `username` (text, unique, optional)
  - `displayName` (text, optional)
  - `bio` (text, optional)
  - `pronouns` (text, optional)
  - `email` (email, required, unique)
  - `emailVisibility` (bool, default: false)
  - `password` (password, required, min: 8)

### personals
- **Fields**:
  - `user_id` (relation to users, required)
  - `content` (text, required, max: 500)
  - `likes_count` (number, default: 0)
  - `comments_count` (number, default: 0)

- **Indexes**:
  - `CREATE INDEX idx_personals_user ON personals(user_id)`
  - `CREATE INDEX idx_personals_created ON personals(created)`

### conversations
- **Fields**:
  - `participant_ids` (json, required) - Array of user IDs
  - `unread_count` (number, default: 0)

- **Indexes**:
  - `CREATE INDEX idx_conversations_updated ON conversations(updated)`

### messages
- **Fields**:
  - `conversation_id` (relation to conversations, required)
  - `sender_id` (relation to users, required)
  - `content` (text, required, max: 2000)
  - `is_read` (bool, default: false)

- **Indexes**:
  - `CREATE INDEX idx_messages_conversation ON messages(conversation_id)`
  - `CREATE INDEX idx_messages_created ON messages(created)`

### proposals
- **Fields**:
  - `title` (text, required, max: 200)
  - `description` (text, required, max: 2000)
  - `author_id` (relation to users, required)
  - `voting_ends_at` (date, required)
  - `status` (select: active, passed, rejected, expired, required)
  - `votes_for` (number, default: 0)
  - `votes_against` (number, default: 0)
  - `votes_abstain` (number, default: 0)

- **Indexes**:
  - `CREATE INDEX idx_proposals_status ON proposals(status)`
  - `CREATE INDEX idx_proposals_created ON proposals(created)`

### votes
- **Fields**:
  - `proposal_id` (relation to proposals, required)
  - `user_id` (relation to users, required)
  - `choice` (select: for, against, abstain, required)

- **Indexes**:
  - `CREATE UNIQUE INDEX idx_votes_user_proposal ON votes(user_id, proposal_id)`

### groups
- **Fields**:
  - `name` (text, required, max: 100)
  - `description` (text, required, max: 500)
  - `creator_id` (relation to users, required)
  - `category` (text, optional) - e.g., "social", "support", "creative", "activism"
  - `is_private` (bool, default: false)
  - `member_count` (number, default: 0)
  - `banner_url` (url, optional)

- **Indexes**:
  - `CREATE INDEX idx_groups_category ON groups(category)`
  - `CREATE INDEX idx_groups_created ON groups(created)`

### group_members
- **Fields**:
  - `group_id` (relation to groups, required, cascade delete)
  - `user_id` (relation to users, required)
  - `role` (select: admin, moderator, member, required, default: member)
  - `joined_at` (date, required)

- **Indexes**:
  - `CREATE UNIQUE INDEX idx_group_members_user_group ON group_members(user_id, group_id)`
  - `CREATE INDEX idx_group_members_group ON group_members(group_id)`

### group_posts
- **Fields**:
  - `group_id` (relation to groups, required, cascade delete)
  - `user_id` (relation to users, required)
  - `content` (text, required, max: 1000)
  - `likes_count` (number, default: 0)
  - `comments_count` (number, default: 0)

- **Indexes**:
  - `CREATE INDEX idx_group_posts_group ON group_posts(group_id)`
  - `CREATE INDEX idx_group_posts_created ON group_posts(created)`

## API Rules (Recommended)

### personals
- **List/View**: `@request.auth.id != ""`
- **Create**: `@request.auth.id != "" && @request.auth.id = @request.data.user_id`
- **Update**: `@request.auth.id = user_id`
- **Delete**: `@request.auth.id = user_id`

### conversations
- **List/View**: `@request.auth.id != "" && participant_ids ~ @request.auth.id`
- **Create**: `@request.auth.id != "" && participant_ids ~ @request.auth.id`
- **Update**: `participant_ids ~ @request.auth.id`
- **Delete**: `participant_ids ~ @request.auth.id`

### messages
- **List/View**: `@request.auth.id != "" && @collection.conversations.participant_ids ~ @request.auth.id`
- **Create**: `@request.auth.id != "" && @request.auth.id = @request.data.sender_id`
- **Update**: `@request.auth.id = sender_id`
- **Delete**: `@request.auth.id = sender_id`

### proposals
- **List/View**: `@request.auth.id != ""`
- **Create**: `@request.auth.id != "" && @request.auth.id = @request.data.author_id`
- **Update**: `@request.auth.id = author_id`
- **Delete**: `@request.auth.id = author_id`

### votes
- **List/View**: `@request.auth.id != ""`
- **Create**: `@request.auth.id != "" && @request.auth.id = @request.data.user_id`
- **Update**: `@request.auth.id = user_id`
- **Delete**: `@request.auth.id = user_id`

### groups
- **List/View**: `@request.auth.id != "" && (is_private = false || @collection.group_members.group_id = id)`
- **Create**: `@request.auth.id != "" && @request.auth.id = @request.data.creator_id`
- **Update**: `@collection.group_members.group_id = id && @collection.group_members.role = "admin"`
- **Delete**: `@collection.group_members.group_id = id && @collection.group_members.role = "admin"`

### group_members
- **List/View**: `@request.auth.id != ""`
- **Create**: `@request.auth.id != "" && (@request.auth.id = @request.data.user_id || @collection.group_members.role ~ "admin")`
- **Update**: `@collection.group_members.group_id = group_id && @collection.group_members.role = "admin"`
- **Delete**: `@request.auth.id = user_id || (@collection.group_members.group_id = group_id && @collection.group_members.role = "admin")`

### group_posts
- **List/View**: `@request.auth.id != "" && @collection.group_members.group_id = group_id`
- **Create**: `@request.auth.id != "" && @request.auth.id = @request.data.user_id && @collection.group_members.group_id = @request.data.group_id`
- **Update**: `@request.auth.id = user_id`
- **Delete**: `@request.auth.id = user_id || @collection.group_members.role ~ "admin|moderator"`

## Setting up PocketBase

1. Download PocketBase from https://pocketbase.io/docs/
2. Run PocketBase: `./pocketbase serve`
3. Open the Admin UI at http://127.0.0.1:8090/_/
4. Create the collections above with their fields
5. Configure API rules for privacy and security
6. Update the `baseUrl` in `lib/core/constants/api_constants.dart`

## Environment Variables

For production, set the PocketBase URL:
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'https://pb.transharbor.org';
```
