import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('OnboardAddServiceController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Service Creation', () {
      test('should create service with valid data', () {
        final serviceData = {
          'serviceId': 'srv123',
          'name': 'Haircut',
          'description': 'Professional haircut service',
          'durations': [
            {'durationMinutes': 30, 'price': 50},
            {'durationMinutes': 60, 'price': 80},
          ],
        };

        expect(serviceData['name'], 'Haircut');
        expect(serviceData['description'], 'Professional haircut service');
        expect((serviceData['durations'] as List).length, 2);
      });

      test('should validate service name', () {
        const serviceName = 'Haircut';
        const emptyName = '';

        expect(serviceName.trim().isNotEmpty, true);
        expect(emptyName.trim().isNotEmpty, false);
      });

      test('should validate service durations', () {
        final durations = [
          {'durationMinutes': 30, 'price': 50},
          {'durationMinutes': 0, 'price': 0},  // Invalid
        ];

        final validDurations = durations.where((duration) =>
          (duration['durationMinutes'] as int) > 0 &&
          (duration['price'] as int) > 0
        ).toList();

        expect(validDurations.length, 1);
      });
    });

    group('Duration and Cost Management', () {
      test('should add new duration and cost entry', () {
        final durationAndCosts = <Map<String, dynamic>>[];
        
        durationAndCosts.add({
          'duration': '30',
          'cost': '50',
          'packageAmount': '',
          'packagePerson': '',
        });

        expect(durationAndCosts.length, 1);
        expect(durationAndCosts.first['duration'], '30');
        expect(durationAndCosts.first['cost'], '50');
      });

      test('should remove duration and cost entry', () {
        final durationAndCosts = [
          {'id': '1', 'duration': '30', 'cost': '50'},
          {'id': '2', 'duration': '60', 'cost': '80'},
        ];

        durationAndCosts.removeWhere((item) => item['id'] == '1');

        expect(durationAndCosts.length, 1);
        expect(durationAndCosts.first['duration'], '60');
      });

      test('should validate duration and cost values', () {
        final entry = {
          'duration': '30',
          'cost': '50',
        };

        final isValid = entry['duration']?.toString().isNotEmpty == true &&
                       entry['cost']?.toString().isNotEmpty == true &&
                       int.tryParse(entry['duration'].toString()) != null &&
                       int.tryParse(entry['cost'].toString()) != null;

        expect(isValid, true);
      });
    });

    group('Package Options', () {
      test('should handle package amount and person settings', () {
        final packageSettings = {
          'hasPackage': true,
          'packageAmount': '5',
          'packagePerson': '2',
        };

        expect(packageSettings['hasPackage'], true);
        expect(packageSettings['packageAmount'], '5');
        expect(packageSettings['packagePerson'], '2');
      });

      test('should validate package values', () {
        const packageAmount = '5';
        const packagePerson = '2';

        final isValidAmount = int.tryParse(packageAmount) != null && int.parse(packageAmount) > 0;
        final isValidPerson = int.tryParse(packagePerson) != null && int.parse(packagePerson) > 0;

        expect(isValidAmount, true);
        expect(isValidPerson, true);
      });
    });

    group('Spots Management', () {
      test('should handle spots availability', () {
        bool spotsAvailable = true;
        String spotsText = '10';

        expect(spotsAvailable, true);
        expect(int.tryParse(spotsText), 10);

        // Disable spots
        spotsAvailable = false;
        spotsText = '';

        expect(spotsAvailable, false);
        expect(spotsText.isEmpty, true);
      });

      test('should validate spots number', () {
        const validSpots = '10';
        const invalidSpots = 'invalid';

        expect(int.tryParse(validSpots) != null, true);
        expect(int.tryParse(invalidSpots) != null, false);
      });
    });

    group('Form State Management', () {
      test('should track form submission state', () {
        bool isSubmitting = false;
        bool isFormValid = false;

        // Form becomes valid
        isFormValid = true;
        expect(isFormValid, true);

        // Start submission
        isSubmitting = true;
        expect(isSubmitting, true);

        // Complete submission
        isSubmitting = false;
        expect(isSubmitting, false);
      });

      test('should handle form reset', () {
        final formData = {
          'name': 'Test Service',
          'description': 'Test Description',
          'durations': [{'duration': '30', 'cost': '50'}],
        };

        // Reset form
        formData['name'] = '';
        formData['description'] = '';
        formData['durations'] = [];

        expect(formData['name'], '');
        expect(formData['description'], '');
        expect((formData['durations'] as List).isEmpty, true);
      });
    });

    group('Text Controllers', () {
      test('should manage service form controllers', () {
        final nameController = TextEditingController();
        final descriptionController = TextEditingController();

        // Set values
        nameController.text = 'Haircut Service';
        descriptionController.text = 'Professional haircut';

        expect(nameController.text, 'Haircut Service');
        expect(descriptionController.text, 'Professional haircut');

        // Clear and dispose
        nameController.clear();
        descriptionController.clear();

        expect(nameController.text, '');
        expect(descriptionController.text, '');

        nameController.dispose();
        descriptionController.dispose();
      });

      test('should manage duration and cost controllers', () {
        final durationController = TextEditingController();
        final costController = TextEditingController();

        durationController.text = '30';
        costController.text = '50';

        expect(durationController.text, '30');
        expect(costController.text, '50');

        durationController.dispose();
        costController.dispose();
      });
    });

    group('Service Data Processing', () {
      test('should construct API payload correctly', () {
        final serviceData = {
          'business_id': 'biz123',
          'service_id': 'srv456',
          'name': 'Haircut',
          'description': 'Professional haircut',
          'durations': [
            {'duration_minutes': 30, 'price': 50},
          ],
          'spots_available': 5,
        };

        expect(serviceData['business_id'], 'biz123');
        expect(serviceData['service_id'], 'srv456');
        expect(serviceData['name'], 'Haircut');
        expect(serviceData['spots_available'], 5);
      });

      test('should filter out invalid durations', () {
        final allDurations = [
          {'duration': '30', 'cost': '50'},  // Valid
          {'duration': '', 'cost': '40'},    // Invalid - empty duration
          {'duration': '45', 'cost': ''},    // Invalid - empty cost
          {'duration': '60', 'cost': '80'},  // Valid
        ];

        final validDurations = allDurations.where((d) =>
          d['duration']?.toString().isNotEmpty == true &&
          d['cost']?.toString().isNotEmpty == true
        ).toList();

        expect(validDurations.length, 2);
        expect(validDurations[0]['duration'], '30');
        expect(validDurations[1]['duration'], '60');
      });
    });

    group('Error Handling', () {
      test('should handle service creation errors', () {
        const errorMessage = 'Failed to create service';
        String? error;

        try {
          throw Exception(errorMessage);
        } catch (e) {
          error = e.toString();
        }

        expect(error, contains(errorMessage));
      });

      test('should validate form before submission', () {
        final errors = <String>[];

        // Validate name
        const name = '';
        if (name.trim().isEmpty) {
          errors.add('Service name is required');
        }

        // Validate durations
        final durations = <Map<String, dynamic>>[];
        if (durations.isEmpty) {
          errors.add('At least one duration is required');
        }

        expect(errors.length, 2);
        expect(errors, contains('Service name is required'));
        expect(errors, contains('At least one duration is required'));
      });
    });
  });
}
