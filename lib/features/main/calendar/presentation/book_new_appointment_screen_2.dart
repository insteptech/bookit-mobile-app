import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BookNewAppointmentScreen2 extends ConsumerStatefulWidget {
  final Map<String, dynamic> partialPayload;
  const BookNewAppointmentScreen2({super.key, required this.partialPayload});

  @override
  ConsumerState<BookNewAppointmentScreen2> createState() =>
      _BookNewAppointmentScreen2State();
}

class _BookNewAppointmentScreen2State
    extends ConsumerState<BookNewAppointmentScreen2> {
  // --- State Variables ---
  bool _isLoading = false;
  String _appointmentSummary = "Loading details...";

  // For Autocomplete Client Search
  final TextEditingController _clientController = TextEditingController();
  final FocusNode _clientFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // Search and selection state
  List<Map<String, dynamic>> _filteredClients = [];
  Map<String, dynamic>? _selectedClient;
  bool _isSearching = false;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _clientController.addListener(_onSearchChanged);
    _clientFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _clientController.removeListener(_onSearchChanged);
    _clientFocusNode.removeListener(_onFocusChanged);
    _clientController.dispose();
    _clientFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  // --- Data and UI Initialization ---
  Future<void> _initializeData() async {
    _buildAppointmentSummary();
    setState(() {
      _isLoading = false;
    });
  }

  void _buildAppointmentSummary() {
    try {
      final payload = widget.partialPayload;
      final duration = payload['duration_minutes'];
      final serviceName = payload['service_name'];
      final practitionerName = payload['practitioner_name'];
      final startTime = DateTime.parse(payload['date']).toLocal();
      final formattedTime = DateFormat('h:mm a').format(startTime);
      final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(startTime);

      setState(() {
        _appointmentSummary =
            "$duration min - $serviceName at [$formattedTime] on [$formattedDate] with $practitionerName";
      });
    } catch (e) {
      setState(() {
        _appointmentSummary = AppTranslationsDelegate.of(context).text("could_not_load_appointment_details");
      });
    }
  }

  // --- Search and Selection Logic ---
  void _onSearchChanged() {
    final query = _clientController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _filteredClients = [];
        _showDropdown = false;
      });
      _updateOverlay();
      return;
    }
    _searchClients(query);
  }

  Future<void> _searchClients(String query) async {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
      _showDropdown = true;
    });
    _updateOverlay();

    try {
      final data = await APIRepository.fetchClients(fullName: query);
      final List<Map<String, dynamic>> clients =
          (data['profile'] != null)
              ? List<Map<String, dynamic>>.from(data['profile'])
              : [];
      setState(() {
        _filteredClients = clients;
        _isSearching = false;
      });
    } catch (e) {
      // debugPrint('Error searching clients: $e');
      setState(() {
        _filteredClients = [];
        _isSearching = false;
      });
    }

    _updateOverlay();
  }

  void _onFocusChanged() {
    if (_clientFocusNode.hasFocus) {
      if (_clientController.text.isNotEmpty) {
        setState(() => _showDropdown = true);
        _updateOverlay();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _showDropdown = false);
          _updateOverlay();
        }
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _removeOverlay();
    if (_showDropdown) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  // --- WIDGETS ---

  Widget _buildOverlayContent() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Searching...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_filteredClients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
            child: Text('No clients found',
                style: TextStyle(color: Colors.grey))),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return InkWell(
          onTap: () => _selectClient(client),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              client['full_name'] ?? 'Unknown Client',
              style: const TextStyle(fontSize: 16, color: Color(0xFF1C1B1F)),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        indent: 16,
        endIndent: 16,
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 68,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 52),
          child: Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: _buildOverlayContent(), // Use the helper method here
            ),
          ),
        ),
      ),
    );
  }

  void _selectClient(Map<String, dynamic> client) {
    setState(() {
      _selectedClient = client;
      _clientController.text = client['full_name'] ?? '';
      _showDropdown = false;
    });
    _updateOverlay();
    _clientFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeLocation = ref.watch(locationsProvider).firstWhere(
        (loc) => loc['id'] == widget.partialPayload['location_id'],
        orElse: () => {'title': '...'});

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
                children: [
                  const SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    "Book a new appointment",
                    style: AppTypography.headingLg,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {},
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: theme.colorScheme.onSurface),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(activeLocation["title"]),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    _appointmentSummary,
                    style: AppTypography.headingSm,
                  ),
                  const SizedBox(height: 24),
                  const Text("Client", style: AppTypography.headingSm),
                  const SizedBox(height: 8),

                  SearchableClientField(
                    layerLink: _layerLink,
                    controller: _clientController,
                    focusNode: _clientFocusNode,
                  ),

                  SizedBox(height: 8,),
              
                  GestureDetector(
                    onTap: () async {
                      final result = await context.push(
                        "/add_new_client",
                        extra: widget.partialPayload,
                      );
                      
                      // If a client was created, select it
                      if (result != null && result is Map<String, dynamic>) {
                        _selectClient(result);
                      }
                    },
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.add_circle_outline_outlined, color: theme.colorScheme.primary, size: 18,),
                      SizedBox(width: 5,),
                      Text(
                        "Add new client",
                        style: AppTypography.bodyMedium.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 20),
              child: PrimaryButton(
                onPressed: _selectedClient != null
                    ? () async{
                      setState(() {
                        _isLoading = true;
                      });
                        List<Map<String,dynamic>> newPayload = [
                          {
                            'business_id': widget.partialPayload['business_id'],
                            'location_id': widget.partialPayload['location_id'],
                            'booked_by': _selectedClient!['id'],
                            'status': 'booked',
                            'business_service_id': widget.partialPayload['business_service_id'],
                            'practitioner': widget.partialPayload['practitioner'],
                            'start_from': widget.partialPayload['start_from'],
                            'end_at': widget.partialPayload['end_at'],
                            'date': widget.partialPayload['date'],
                            'user_id': widget.partialPayload['user_id'],
                          }
                        ];
                        await APIRepository.bookAppointment(payload: newPayload);
                        context.go("/home_screen");
                      }
                    : null,
                isDisabled: (_selectedClient == null || _isLoading),
                text: "Confirm booking",
              ),
            ),
          ],
        ),
      ),
    );
  }
}