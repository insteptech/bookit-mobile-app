import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/widgets/appointment_summary_widget.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';

void main() {
  group('AppointmentSummaryWidget Tests', () {
    Widget createTestWidget(Map<String, dynamic> partialPayload) {
      return MaterialApp(
        localizationsDelegates: const [
          AppTranslationsDelegate(),
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ar', 'SA'),
        ],
        home: Scaffold(
          body: AppointmentSummaryWidget(
            partialPayload: partialPayload,
          ),
        ),
      );
    }

    testWidgets('should display appointment summary with complete data', (tester) async {
      // Arrange
      final partialPayload = {
        'date': '2024-01-15',
        'duration_minutes': 60,
        'service_name': 'Massage Therapy',
        'practitioner_name': 'Dr. Smith',
      };

      // Act
      await tester.pumpWidget(createTestWidget(partialPayload));

      // Assert
      expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // The exact text depends on the DateFormatterService implementation
      // but we can verify that the widget renders without errors
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, isNotNull);
      expect(textWidget.data!.isNotEmpty, true);
    });

    testWidgets('should display appointment summary with partial data', (tester) async {
      // Arrange
      final partialPayload = {
        'date': '2024-01-15',
        'service_name': 'Massage Therapy',
        // Missing duration_minutes and practitioner_name
      };

      // Act
      await tester.pumpWidget(createTestWidget(partialPayload));

      // Assert
      expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // Should still render without crashing
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, isNotNull);
    });

    testWidgets('should display appointment summary with empty data', (tester) async {
      // Arrange
      final partialPayload = <String, dynamic>{};

      // Act
      await tester.pumpWidget(createTestWidget(partialPayload));

      // Assert
      expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // Should render fallback message or handle gracefully
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, isNotNull);
    });

    testWidgets('should display appointment summary with null values', (tester) async {
      // Arrange
      final partialPayload = {
        'date': null,
        'duration_minutes': null,
        'service_name': null,
        'practitioner_name': null,
      };

      // Act
      await tester.pumpWidget(createTestWidget(partialPayload));

      // Assert
      expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // Should handle null values gracefully
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, isNotNull);
    });

    testWidgets('should use correct text style', (tester) async {
      // Arrange
      final partialPayload = {
        'date': '2024-01-15',
        'duration_minutes': 60,
        'service_name': 'Massage Therapy',
        'practitioner_name': 'Dr. Smith',
      };

      // Act
      await tester.pumpWidget(createTestWidget(partialPayload));

      // Assert
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style, isNotNull);
      // The exact style check would depend on AppTypography.headingSm implementation
    });

    testWidgets('should handle different date formats', (tester) async {
      // Test different date formats
      final dateFormats = [
        '2024-01-15',
        '15/01/2024',
        '2024-01-15T10:30:00Z',
        'January 15, 2024',
        '2024-1-15', // Single digit month
      ];

      for (final dateFormat in dateFormats) {
        final partialPayload = {
          'date': dateFormat,
          'duration_minutes': 30,
          'service_name': 'Test Service',
          'practitioner_name': 'Test Practitioner',
        };

        // Act
        await tester.pumpWidget(createTestWidget(partialPayload));

        // Assert
        expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
        
        // Should handle different date formats gracefully
        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.data, isNotNull);
        expect(textWidget.data!.isNotEmpty, true);
      }
    });

    testWidgets('should handle different duration values', (tester) async {
      // Test different duration values
      final durations = [15, 30, 45, 60, 90, 120, 0, -1]; // Including edge cases

      for (final duration in durations) {
        final partialPayload = {
          'date': '2024-01-15',
          'duration_minutes': duration,
          'service_name': 'Test Service',
          'practitioner_name': 'Test Practitioner',
        };

        // Act
        await tester.pumpWidget(createTestWidget(partialPayload));

        // Assert
        expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
        
        // Should handle different duration values gracefully
        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.data, isNotNull);
        expect(textWidget.data!.isNotEmpty, true);
      }
    });

    testWidgets('should handle special characters in service and practitioner names', (tester) async {
      // Arrange
      final partialPayload = {
        'date': '2024-01-15',
        'duration_minutes': 60,
        'service_name': 'Massage Thérapie & Acupuncture (Special)',
        'practitioner_name': 'Dr. Jean-François O\'Connor',
      };

      // Act
      await tester.pumpWidget(createTestWidget(partialPayload));

      // Assert
      expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // Should handle special characters gracefully
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, isNotNull);
      expect(textWidget.data!.isNotEmpty, true);
    });

    testWidgets('should handle very long service and practitioner names', (tester) async {
      // Arrange
      final partialPayload = {
        'date': '2024-01-15',
        'duration_minutes': 60,
        'service_name': 'Very Long Service Name That Might Cause Layout Issues Because It Contains Too Many Characters And Should Be Handled Properly',
        'practitioner_name': 'Dr. Very Long Practitioner Name That Also Might Cause Layout Issues',
      };

      // Act
      await tester.pumpWidget(createTestWidget(partialPayload));

      // Assert
      expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // Should handle long text gracefully
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, isNotNull);
      expect(textWidget.data!.isNotEmpty, true);
    });

    testWidgets('should handle empty strings in payload', (tester) async {
      // Arrange
      final partialPayload = {
        'date': '',
        'duration_minutes': 0,
        'service_name': '',
        'practitioner_name': '',
      };

      // Act
      await tester.pumpWidget(createTestWidget(partialPayload));

      // Assert
      expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // Should handle empty strings gracefully
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, isNotNull);
    });

    testWidgets('should handle mixed data types in payload', (tester) async {
      // Arrange
      final partialPayload = {
        'date': '2024-01-15',
        'duration_minutes': '60', // String instead of int
        'service_name': 123, // Number instead of string
        'practitioner_name': true, // Boolean instead of string
      };

      // Act
      await tester.pumpWidget(createTestWidget(partialPayload));

      // Assert
      expect(find.byType(AppointmentSummaryWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // Should handle type mismatches gracefully
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.data, isNotNull);
    });
  });
}
