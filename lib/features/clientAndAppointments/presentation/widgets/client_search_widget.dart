import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import '../../provider.dart';
import '../../application/state/client_state.dart';

class ClientSearchWidget extends ConsumerStatefulWidget {
  final LayerLink layerLink;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(Map<String, dynamic>) onClientSelected;

  const ClientSearchWidget({
    super.key,
    required this.layerLink,
    required this.controller,
    required this.focusNode,
    required this.onClientSelected,
  });

  @override
  ConsumerState<ClientSearchWidget> createState() => _ClientSearchWidgetState();
}

class _ClientSearchWidgetState extends ConsumerState<ClientSearchWidget> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller.text.trim();
    final clientController = ref.read(clientControllerProvider.notifier);
    
    clientController.updateSearchQuery(query);
    
    if (query.isEmpty) {
      _updateOverlay();
      return;
    }
    
    clientController.searchClients(query);
    _updateOverlay();
  }

  void _onFocusChanged() {
    final clientController = ref.read(clientControllerProvider.notifier);
    
    if (widget.focusNode.hasFocus) {
      if (widget.controller.text.isNotEmpty) {
        clientController.setShowDropdown(true);
        _updateOverlay();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          clientController.setShowDropdown(false);
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
    final clientState = ref.read(clientControllerProvider);
    if (clientState.showDropdown && widget.focusNode.hasFocus) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _selectClient(Map<String, dynamic> client) {
    final clientController = ref.read(clientControllerProvider.notifier);
    clientController.selectClient(client);
    widget.controller.text = client['full_name'] ?? '';
    _updateOverlay();
    widget.focusNode.unfocus();
    widget.onClientSelected(client);
  }

  Widget _buildOverlayContent() {
    final clientState = ref.watch(clientControllerProvider);

    if (clientState.isSearching) {
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

    if (clientState.filteredClients.isEmpty) {
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
      itemCount: clientState.filteredClients.length,
      itemBuilder: (context, index) {
        final client = clientState.filteredClients[index];
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
          link: widget.layerLink,
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
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  return _buildOverlayContent();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to client state changes and update overlay accordingly
    ref.listen<ClientState>(clientControllerProvider, (previous, next) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateOverlay();
        });
      }
    });
    
    return SearchableClientField(
      layerLink: widget.layerLink,
      controller: widget.controller,
      focusNode: widget.focusNode,
    );
  }
}
