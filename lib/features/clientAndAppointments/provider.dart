import 'package:flutter_riverpod/flutter_riverpod.dart';

// Domain imports
import 'domain/repositories/appointment_repository.dart';
import 'domain/repositories/client_repository.dart';
import 'domain/usecases/get_practitioners.dart';
import 'domain/usecases/get_services.dart';
import 'domain/usecases/book_appointment.dart';
import 'domain/usecases/get_clients.dart';
import 'domain/usecases/create_client.dart';
import 'domain/usecases/create_client_and_book_appointment.dart';

// Data imports
import 'data/datasources/appointment_remote_datasource.dart';
import 'data/datasources/client_remote_datasource.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'data/repositories/client_repository_impl.dart';

// Application imports
import 'application/controllers/appointment_controller.dart';
import 'application/controllers/client_controller.dart';
import 'application/state/appointment_state.dart';
import 'application/state/client_state.dart';

// === Data Sources ===
final appointmentRemoteDataSourceProvider = Provider<AppointmentRemoteDataSource>(
  (ref) => AppointmentRemoteDataSourceImpl(),
);

final clientRemoteDataSourceProvider = Provider<ClientRemoteDataSource>(
  (ref) => ClientRemoteDataSourceImpl(),
);

// === Repositories ===
final appointmentRepositoryProvider = Provider<AppointmentRepository>(
  (ref) => AppointmentRepositoryImpl(
    ref.read(appointmentRemoteDataSourceProvider),
  ),
);

final clientRepositoryProvider = Provider<ClientRepository>(
  (ref) => ClientRepositoryImpl(
    ref.read(clientRemoteDataSourceProvider),
  ),
);

// === Use Cases ===
final getPractitionersProvider = Provider<GetPractitioners>(
  (ref) => GetPractitioners(ref.read(appointmentRepositoryProvider)),
);

final getServicesProvider = Provider<GetServices>(
  (ref) => GetServices(ref.read(appointmentRepositoryProvider)),
);

final bookAppointmentProvider = Provider<BookAppointment>(
  (ref) => BookAppointment(ref.read(appointmentRepositoryProvider)),
);

final getClientsProvider = Provider<GetClients>(
  (ref) => GetClients(ref.read(clientRepositoryProvider)),
);

final createClientProvider = Provider<CreateClient>(
  (ref) => CreateClient(ref.read(clientRepositoryProvider)),
);

final createClientAndBookAppointmentProvider = Provider<CreateClientAndBookAppointment>(
  (ref) => CreateClientAndBookAppointment(ref.read(clientRepositoryProvider)),
);

// === Controllers ===
final appointmentControllerProvider = StateNotifierProvider<AppointmentController, AppointmentState>(
  (ref) => AppointmentController(
    ref.read(getPractitionersProvider),
    ref.read(getServicesProvider),
    ref.read(bookAppointmentProvider),
  ),
);

final clientControllerProvider = StateNotifierProvider<ClientController, ClientState>(
  (ref) => ClientController(
    ref.read(getClientsProvider),
    ref.read(createClientProvider),
    ref.read(createClientAndBookAppointmentProvider),
  ),
);
