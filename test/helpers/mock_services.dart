import 'package:transharbor/core/services/pocketbase_service.dart';
import 'package:transharbor/core/services/storage_service.dart';
import 'package:transharbor/core/services/api_service.dart';

// Fake implementations for testing that don't require platform channels
class FakePocketBaseService implements PocketBaseService {
  @override
  bool get isAuthenticated => false;

  @override
  Future<void> logout() async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStorageService implements StorageService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeApiService implements ApiService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
