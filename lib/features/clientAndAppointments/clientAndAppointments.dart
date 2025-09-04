// Domain exports
export 'domain/entities/appointment.dart';
export 'domain/entities/client.dart';
export 'domain/entities/practitioner.dart';
export 'domain/entities/service.dart';

export 'domain/repositories/appointment_repository.dart';
export 'domain/repositories/client_repository.dart';

export 'domain/usecases/get_practitioners.dart';
export 'domain/usecases/get_services.dart';
export 'domain/usecases/book_appointment.dart';
export 'domain/usecases/get_clients.dart';
export 'domain/usecases/create_client.dart';

// Data exports
export 'data/models/practitioner_model.dart';
export 'data/models/service_model.dart';
export 'data/models/client_model.dart';

export 'data/datasources/appointment_remote_datasource.dart';
export 'data/datasources/client_remote_datasource.dart';

export 'data/repositories/appointment_repository_impl.dart';
export 'data/repositories/client_repository_impl.dart';

// Application exports
export 'application/controllers/appointment_controller.dart';
export 'application/controllers/client_controller.dart';
export 'application/state/appointment_state.dart';
export 'application/state/client_state.dart';

// Provider exports
export 'provider.dart';
