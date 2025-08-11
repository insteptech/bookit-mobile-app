import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/controllers/appointment_controller.dart';
import 'application/controllers/client_controller.dart';
import 'application/state/appointment_state.dart';
import 'application/state/client_state.dart';
import 'data/services/appointment_api_service.dart';
import 'data/services/client_api_service.dart';

// Service providers
final appointmentApiServiceProvider = Provider<AppointmentApiService>((ref) {
  return AppointmentApiService();
});

final clientApiServiceProvider = Provider<ClientApiService>((ref) {
  return ClientApiService();
});

// Controller providers
final appointmentControllerProvider = StateNotifierProvider<AppointmentController, AppointmentState>((ref) {
  final apiService = ref.watch(appointmentApiServiceProvider);
  return AppointmentController(apiService);
});

final clientControllerProvider = StateNotifierProvider<ClientController, ClientState>((ref) {
  final apiService = ref.watch(clientApiServiceProvider);
  return ClientController(apiService);
});
