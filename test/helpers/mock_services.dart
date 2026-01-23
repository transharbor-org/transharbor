import 'package:mockito/mockito.dart';
import 'package:transharbor/core/services/pocketbase_service.dart';
import 'package:transharbor/core/services/storage_service.dart';
import 'package:transharbor/core/services/api_service.dart';

class MockPocketBaseService extends Mock implements PocketBaseService {}

class MockStorageService extends Mock implements StorageService {}

class MockApiService extends Mock implements ApiService {}
