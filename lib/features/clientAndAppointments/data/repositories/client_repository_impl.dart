import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_datasource.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;

  const ClientRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Client>> getClients({String? searchQuery}) async {
    final models = await remoteDataSource.getClients(searchQuery: searchQuery);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Client> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    DateTime? dateOfBirth,
    String? address,
    String? notes,
  }) async {
    final model = await remoteDataSource.createClient(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      address: address,
      notes: notes,
    );
    return model.toEntity();
  }

  @override
  Future<Map<String, dynamic>> createClientAccountAndBookAppointment({
    required String fullName,
    required String email,
    required String phone,
    required Map<String, dynamic> appointmentData,
    String? gender,
    DateTime? dateOfBirth,
    String? preferredLanguage,
    String? statusReason,
    String? classId,
    String? rescheduledFrom,
    bool? isCancelled,
    String? preferredContactMethod,
    bool? marketingConsent,
    String? clientNotes,
  }) async {
    return await remoteDataSource.createClientAccountAndBookAppointment(
      fullName: fullName,
      email: email,
      phone: phone,
      appointmentData: appointmentData,
      gender: gender,
      dateOfBirth: dateOfBirth,
      preferredLanguage: preferredLanguage,
      statusReason: statusReason,
      classId: classId,
      rescheduledFrom: rescheduledFrom,
      isCancelled: isCancelled,
      preferredContactMethod: preferredContactMethod,
      marketingConsent: marketingConsent,
      clientNotes: clientNotes,
    );
  }

  @override
  Future<Client> updateClient(Client client) {
    // TODO: Implement when API is available
    throw UnimplementedError();
  }

  @override
  Future<void> deleteClient(String clientId) {
    // TODO: Implement when API is available
    throw UnimplementedError();
  }
}
