import '../entities/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients({String? searchQuery});
  Future<Client> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    DateTime? dateOfBirth,
    String? address,
    String? notes,
  });
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
  });
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(String clientId);
}
