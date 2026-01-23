class ApiConstants {
  // PocketBase URL - Update with your PocketBase instance
  static const String baseUrl = 'http://127.0.0.1:8090';
  // For production: static const String baseUrl = 'https://pb.transharbor.org';
  
  // PocketBase Collections
  static const String usersCollection = 'users';
  static const String personalsCollection = 'personals';
  static const String messagesCollection = 'messages';
  static const String conversationsCollection = 'conversations';
  static const String proposalsCollection = 'proposals';
  static const String votesCollection = 'votes';
  static const String groupsCollection = 'groups';
  static const String groupMembersCollection = 'group_members';
  static const String groupPostsCollection = 'group_posts';
  
  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
