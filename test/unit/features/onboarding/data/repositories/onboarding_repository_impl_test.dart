import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/core/models/business_model.dart';
import 'package:bookit_mobile_app/core/models/category_model.dart';
import 'package:bookit_mobile_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:bookit_mobile_app/features/onboarding/data/services/onboarding_api_service.dart';

class MockOnboardingApiService implements OnboardingApiService {
  BusinessModel? _businessToReturn;
  List<CategoryModel>? _categoriesToReturn;
  Exception? _exceptionToThrow;
  Map<String, dynamic>? _lastPayload;

  @override
  String get categoryUrl => 'https://api.example.com/categories';

  void setBusinessToReturn(BusinessModel business) {
    _businessToReturn = business;
  }

  void setCategoriesToReturn(List<CategoryModel> categories) {
    _categoriesToReturn = categories;
  }

  void setExceptionToThrow(Exception exception) {
    _exceptionToThrow = exception;
  }

  Map<String, dynamic>? get lastPayload => _lastPayload;

  @override
  Future<BusinessModel> submitOnboardingStep({required Map<String, dynamic> payload}) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    _lastPayload = payload;
    return _businessToReturn!;
  }

  @override
  Future<void> submitOnboardingStepVoid({required Map<String, dynamic> payload}) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    _lastPayload = payload;
  }

  @override
  Future<BusinessModel> getBusinessDetails({String? businessId}) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _businessToReturn!;
  }

  @override
  Future<List<CategoryModel>> getCategories({String? categoryLevel}) async {
    if (_exceptionToThrow != null) throw _exceptionToThrow!;
    return _categoriesToReturn!;
  }
}

void main() {
  late OnboardingRepositoryImpl repository;
  late MockOnboardingApiService mockApiService;

  setUp(() {
    mockApiService = MockOnboardingApiService();
    repository = OnboardingRepositoryImpl(mockApiService);
  });

  group('OnboardingRepositoryImpl', () {
    group('submitBusinessInfo', () {
      test('should call API service with correct payload and return business model', () async {
        // Arrange
        final expectedBusiness = BusinessModel(
          id: 'biz123',
          userId: 'user123',
          name: 'Test Business',
          email: 'test@example.com',
          phone: '+1234567890',
          website: 'https://example.com',
          activeStep: 'locations',
          isOnboardingComplete: false,
          locations: [],
          businessCategories: [],
          businessServices: [],
        );

        mockApiService.setBusinessToReturn(expectedBusiness);

        // Act
        final result = await repository.submitBusinessInfo(
          name: 'Test Business',
          email: 'test@example.com',
          phone: '+1234567890',
          website: 'https://example.com',
          businessId: 'biz123',
        );

        // Assert
        expect(result, expectedBusiness);
        
        final payload = mockApiService.lastPayload!;
        expect(payload['step'], 'about_you');
        expect(payload['data']['name'], 'Test Business');
        expect(payload['data']['email'], 'test@example.com');
        expect(payload['data']['phone'], '+1234567890');
        expect(payload['data']['website'], 'https://example.com');
        expect(payload['data']['business_id'], 'biz123');
        expect(payload['data']['active_step'], 'locations');
      });

      test('should handle business info submission without optional fields', () async {
        // Arrange
        final expectedBusiness = BusinessModel(
          id: 'biz123',
          userId: 'user123',
          name: 'Test Business',
          email: 'test@example.com',
          phone: '+1234567890',
          activeStep: 'locations',
          isOnboardingComplete: false,
          locations: [],
          businessCategories: [],
          businessServices: [],
        );

        mockApiService.setBusinessToReturn(expectedBusiness);

        // Act
        final result = await repository.submitBusinessInfo(
          name: 'Test Business',
          email: 'test@example.com',
          phone: '+1234567890',
        );

        // Assert
        expect(result, expectedBusiness);

        final payload = mockApiService.lastPayload!;
        expect(payload['data']['website'], isNull);
        expect(payload['data']['business_id'], isNull);
      });

      test('should propagate exceptions from API service', () async {
        // Arrange
        mockApiService.setExceptionToThrow(Exception('API Error'));

        // Act & Assert
        expect(
          () => repository.submitBusinessInfo(
            name: 'Test Business',
            email: 'test@example.com',
            phone: '+1234567890',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getBusinessDetails', () {
      test('should call API service and return business model', () async {
        // Arrange
        final expectedBusiness = BusinessModel(
          id: 'biz123',
          userId: 'user123',
          name: 'Test Business',
          email: 'test@example.com',
          phone: '+1234567890',
          activeStep: 'locations',
          isOnboardingComplete: false,
          locations: [],
          businessCategories: [],
          businessServices: [],
        );

        mockApiService.setBusinessToReturn(expectedBusiness);

        // Act
        final result = await repository.getBusinessDetails(businessId: 'biz123');

        // Assert
        expect(result, expectedBusiness);
      });

      test('should handle null businessId', () async {
        // Arrange
        final expectedBusiness = BusinessModel(
          id: 'biz123',
          userId: 'user123',
          name: 'Test Business',
          email: 'test@example.com',
          phone: '+1234567890',
          activeStep: 'locations',
          isOnboardingComplete: false,
          locations: [],
          businessCategories: [],
          businessServices: [],
        );

        mockApiService.setBusinessToReturn(expectedBusiness);

        // Act
        final result = await repository.getBusinessDetails();

        // Assert
        expect(result, expectedBusiness);
      });
    });

    group('submitLocationInfo', () {
      test('should call API service with correct payload', () async {
        // Arrange
        final locations = [
          {'address': '123 Main St', 'city': 'Anytown'},
          {'address': '456 Oak Ave', 'city': 'Other City'},
        ];

        // Act
        await repository.submitLocationInfo(
          businessId: 'biz123',
          locations: locations,
        );

        // Assert
        final payload = mockApiService.lastPayload!;
        expect(payload['step'], 'locations');
        expect(payload['data']['business_id'], 'biz123');
        expect(payload['data']['locations'], locations);
      });

      test('should handle empty locations', () async {
        // Act
        await repository.submitLocationInfo(
          businessId: 'biz123',
          locations: [],
        );

        // Assert
        final payload = mockApiService.lastPayload!;
        expect(payload['data']['locations'], isEmpty);
      });
    });

    group('getCategories', () {
      test('should call API service and return categories list', () async {
        // Arrange
        final expectedCategories = [
          CategoryModel(
            id: 'cat1',
            parentId: null,
            slug: 'category-1',
            name: 'Category 1',
            description: 'Description 1',
            level: 1,
            isActive: true,
          ),
          CategoryModel(
            id: 'cat2',
            parentId: null,
            slug: 'category-2',
            name: 'Category 2',
            description: 'Description 2',
            level: 1,
            isActive: true,
          ),
        ];

        mockApiService.setCategoriesToReturn(expectedCategories);

        // Act
        final result = await repository.getCategories(categoryLevel: 'level1');

        // Assert
        expect(result, expectedCategories);
      });

      test('should handle null category level', () async {
        // Arrange
        final expectedCategories = <CategoryModel>[];
        mockApiService.setCategoriesToReturn(expectedCategories);

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result, expectedCategories);
      });
    });

    group('updateCategory', () {
      test('should call API service with correct payload', () async {
        // Act
        await repository.updateCategory(
          id: 'step123',
          businessId: 'biz123',
          categoryId: 'cat456',
        );

        // Assert
        final payload = mockApiService.lastPayload!;
        expect(payload['step'], 'categories');
        expect(payload['data']['id'], 'step123');
        expect(payload['data']['business_id'], 'biz123');
        expect(payload['data']['category_id'], 'cat456');
      });

      test('should handle null id', () async {
        // Act
        await repository.updateCategory(
          businessId: 'biz123',
          categoryId: 'cat456',
        );

        // Assert
        final payload = mockApiService.lastPayload!;
        expect(payload['data']['id'], isNull);
      });
    });

    group('createServices', () {
      test('should call API service with correct payload', () async {
        // Arrange
        final services = [
          {'name': 'Service 1', 'price': 100},
          {'name': 'Service 2', 'price': 200},
        ];

        // Act
        await repository.createServices(services: services);

        // Assert
        final payload = mockApiService.lastPayload!;
        expect(payload['step'], 'services');
        expect(payload['data']['services'], services);
      });

      test('should handle empty services list', () async {
        // Act
        await repository.createServices(services: []);

        // Assert
        final payload = mockApiService.lastPayload!;
        expect(payload['data']['services'], isEmpty);
      });
    });

    group('updateService', () {
      test('should call API service with correct payload', () async {
        // Arrange
        final details = [
          {'detail': 'Duration: 60 min'},
          {'detail': 'Includes materials'},
        ];

        // Act
        await repository.updateService(allDetails: details);

        // Assert
        final payload = mockApiService.lastPayload!;
        expect(payload['step'], 'service_details');
        expect(payload['data']['details'], details);
      });

      test('should handle empty details list', () async {
        // Act
        await repository.updateService(allDetails: []);

        // Assert
        final payload = mockApiService.lastPayload!;
        expect(payload['data']['details'], isEmpty);
      });
    });
  });
}
