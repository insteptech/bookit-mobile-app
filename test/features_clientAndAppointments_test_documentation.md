# Client and Appointments Testing Documentation

This document provides an overview of the comprehensive test suite created for the `features/clientAndAppointments` module.

## Test Structure

The test suite is organized into the following categories:

### 1. Unit Tests (`test/unit/features/clientAndAppointments/`)

#### Domain Layer Tests
- **Entities** (`domain/entities/`)
  - `client_test.dart` - Tests for Client entity including validation, copyWith functionality, and fullName getter
  - `appointment_test.dart` - Tests for Appointment entity with various status and duration scenarios
  - `practitioner_test.dart` - Tests for Practitioner entity with complex schedule and service handling
  - `service_test.dart` - Tests for Service and ServiceDuration entities with pricing and duration variations

- **Use Cases** (`domain/usecases/`)
  - `get_clients_test.dart` - Tests for client search functionality with various query scenarios
  - `create_client_test.dart` - Tests for client creation with validation and error handling
  - `get_practitioners_test.dart` - Tests for practitioner retrieval by location
  - `get_services_test.dart` - Tests for service listing with different types and configurations
  - `book_appointment_test.dart` - Tests for appointment booking with various parameters

#### Application Layer Tests
- **State Management** (`application/state/`)
  - `client_state_test.dart` - Tests for ClientState including all properties and copyWith functionality
  - `appointment_state_test.dart` - Tests for AppointmentState with complex data structures and validation

- **Controllers** (`application/controllers/`)
  - `client_controller_test.dart` - Tests for ClientController including search, selection, and creation flows
  - `appointment_controller_test.dart` - Tests for AppointmentController covering practitioner/service selection and booking

### 2. Widget Tests (`test/widget/features/clientAndAppointments/`)

#### Presentation Layer Tests
- **Widgets** (`presentation/widgets/`)
  - `client_search_widget_test.dart` - Tests for client search UI component including dropdown behavior, selection, and error states
  - `appointment_summary_widget_test.dart` - Tests for appointment summary display with various data scenarios

### 3. Integration Tests (`test/integration/features/clientAndAppointments/`)

- `client_and_appointments_integration_test.dart` - End-to-end tests for complete user flows including client search, appointment booking, and error scenarios

## Test Coverage Areas

### Functional Testing
- ✅ Client search and filtering
- ✅ Client creation with validation
- ✅ Practitioner retrieval by location
- ✅ Service listing and filtering
- ✅ Appointment booking flow
- ✅ State management transitions
- ✅ Error handling and recovery

### Edge Cases Covered
- ✅ Empty search results
- ✅ Network failures
- ✅ Invalid data formats
- ✅ Null and undefined values
- ✅ Special characters in names
- ✅ Large datasets
- ✅ Rapid user interactions
- ✅ Multiple name parts (e.g., "Jean-François de la Cruz")
- ✅ Different date and time formats
- ✅ Various duration values (15min to 2+ hours)

### User Experience Testing
- ✅ Loading states
- ✅ Error message display
- ✅ Dropdown behavior
- ✅ Focus management
- ✅ Text field updates
- ✅ Selection feedback

### Data Validation Testing
- ✅ Email format validation
- ✅ Phone number handling
- ✅ Required field validation
- ✅ Type safety and conversion
- ✅ Boundary value testing

## Running the Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Categories

#### Unit Tests Only
```bash
flutter test test/unit/features/clientAndAppointments/
```

#### Widget Tests Only
```bash
flutter test test/widget/features/clientAndAppointments/
```

#### Integration Tests
```bash
flutter test integration_test/
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run Specific Test Files
```bash
# Test specific entity
flutter test test/unit/features/clientAndAppointments/domain/entities/client_test.dart

# Test specific controller
flutter test test/unit/features/clientAndAppointments/application/controllers/client_controller_test.dart

# Test specific widget
flutter test test/widget/features/clientAndAppointments/presentation/widgets/client_search_widget_test.dart
```

## Test Dependencies

The test suite uses the following dependencies:
- `flutter_test` - Core testing framework
- `mockito` - Mocking framework for dependencies
- `flutter_riverpod` - State management testing
- `integration_test` - Integration testing framework

## Mock Setup

Tests use mock implementations of:
- `ClientRepository` - For client data operations
- `AppointmentRepository` - For appointment and practitioner operations
- `GetClients` use case - For client search functionality
- `CreateClient` use case - For client creation
- `GetPractitioners` use case - For practitioner retrieval
- `GetServices` use case - For service listing
- `BookAppointment` use case - For appointment booking

## Test Data Examples

### Sample Client Data
```dart
Client(
  id: '1',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john.doe@example.com',
  phoneNumber: '+1234567890',
  dateOfBirth: DateTime(1990, 5, 15),
  address: '123 Main St, City, State',
  notes: 'Prefers morning appointments',
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
)
```

### Sample Appointment Data
```dart
Appointment(
  id: 'apt-1',
  businessId: 'biz-1',
  locationId: 'loc-1',
  businessServiceId: 'service-1',
  practitionerId: 'prac-1',
  practitionerName: 'Dr. Smith',
  serviceName: 'Consultation',
  durationMinutes: 60,
  startTime: DateTime(2024, 1, 15, 14, 0, 0),
  endTime: DateTime(2024, 1, 15, 15, 0, 0),
  status: 'confirmed',
  clientId: 'client-1',
  clientName: 'John Doe',
)
```

## Test Maintenance

### Adding New Tests
1. Follow the existing directory structure
2. Use descriptive test names that explain the scenario
3. Include both positive and negative test cases
4. Add appropriate mocking for external dependencies
5. Update this documentation when adding new test categories

### Test Naming Conventions
- Use descriptive names: `should create client with all required fields`
- Include the expected behavior: `should handle repository exception`
- Group related tests using `group()` blocks
- Use consistent naming patterns across test files

### Best Practices
- Keep tests focused and atomic
- Use appropriate setup and teardown methods
- Mock external dependencies consistently
- Test edge cases and error scenarios
- Maintain test data consistency
- Document complex test scenarios

## Troubleshooting

### Common Issues
1. **Mock generation errors**: Ensure mockito annotations are correct
2. **Widget test failures**: Check that all required dependencies are provided
3. **Integration test timeouts**: Verify app navigation and UI element availability
4. **State management issues**: Ensure proper provider overrides in tests

### Performance Considerations
- Tests should complete within reasonable time limits (< 5 seconds for complex scenarios)
- Large dataset tests should verify performance benchmarks
- Memory usage should be monitored for tests with extensive data

## Future Enhancements

Potential areas for test expansion:
- Accessibility testing
- Localization testing
- Performance benchmarking
- Visual regression testing
- API contract testing
- Error recovery scenarios
- Offline functionality testing
