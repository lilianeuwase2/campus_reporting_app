import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import 'loading_button.dart';

// Shown on the details screen to staff only: change a report's status
// and leave a note the student will see
class StaffStatusPanel extends StatefulWidget {
  final Incident incident;
  const StaffStatusPanel({super.key, required this.incident});

  @override
  State<StaffStatusPanel> createState() => _StaffStatusPanelState();
}

class _StaffStatusPanelState extends State<StaffStatusPanel> {
  // Staff move reports forward. "Submitted" is only ever set by the student,
  // which also means a student can't delete a report staff already handled.
  static final _options = statusLabels.keys
      .where((s) => s != 'submitted')
      .toList();

  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  String? _newStatus; // local form state, so setState is fine

  @override
  void initState() {
    super.initState();
    final current = widget.incident.status;
    _newStatus = _options.contains(current) ? current : null;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  String? _validateNote(String? value) {
    final note = value?.trim() ?? '';
    if (_newStatus == 'rejected' && note.isEmpty) {
      return 'Tell the student why the report is rejected';
    }
    if (_newStatus == widget.incident.status && note.isEmpty) {
      return 'Choose a new status or add a note';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final error = await context.read<IncidentProvider>().updateStatus(
      incident: widget.incident,
      newStatus: _newStatus!,
      note: _noteCtrl.text,
      staffUid: auth.uid!,
      staffName: auth.nameOrEmail,
    );
    if (!mounted) return;
    if (error == null) _noteCtrl.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Status updated')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saving = context.watch<IncidentProvider>().isUpdatingStatus;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.admin_panel_settings_outlined),
                  const SizedBox(width: 8),
                  Text('Staff: update status', style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _newStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final s in _options)
                    DropdownMenuItem(value: s, child: Text(statusLabels[s]!)),
                ],
                onChanged: (v) => setState(() => _newStatus = v),
                validator: (v) => v == null ? 'Choose a status' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note for the student',
                  hintText: 'e.g. Plumber booked for 2pm today',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: _validateNote,
              ),
              const SizedBox(height: 8),
              LoadingButton(
                label: 'Save update',
                isLoading: saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
