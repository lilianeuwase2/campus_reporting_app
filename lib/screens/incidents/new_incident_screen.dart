import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/photo_picker_field.dart';

class NewIncidentScreen extends StatefulWidget {
  const NewIncidentScreen({super.key});

  @override
  State<NewIncidentScreen> createState() => _NewIncidentScreenState();
}

class _NewIncidentScreenState extends State<NewIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _category; // local form state, so setState is fine
  bool _anonymous = false;
  File? _photo; // the chosen photo, not uploaded until Submit

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Stop if any field is invalid: the red messages show under the fields
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final error = await context.read<IncidentProvider>().submitIncident(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      category: _category!,
      location: _locationCtrl.text,
      anonymous: _anonymous,
      uid: auth.uid!,
      name: auth.nameOrEmail,
      photo: _photo,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Report submitted')));
    if (error == null) Navigator.pop(context); // back to the list
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<IncidentProvider>().isSubmitting;
    return Scaffold(
      appBar: AppBar(title: const Text('New report')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Broken lamp in the pod near Morocco',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length < 5)
                      ? 'Title must be at least 5 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categoryLabels.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Row(
                            children: [
                              Icon(categoryIcons[e.key], size: 20),
                              const SizedBox(width: 8),
                              Text(e.value),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) => v == null ? 'Choose a category' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g. Social Commons',
                    prefixIcon: Icon(Icons.place_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Tell staff where the problem is'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is wrong, and since when?',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length < 15)
                      ? 'Please describe the problem (at least 15 characters)'
                      : null,
                ),
                const SizedBox(height: 8),
                PhotoPickerField(
                  photo: _photo,
                  enabled: !submitting, // can't change it while uploading
                  onChanged: (file) => setState(() => _photo = file),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Report anonymously'),
                  subtitle: const Text("Other students won't see your name"),
                  value: _anonymous,
                  onChanged: (v) => setState(() => _anonymous = v),
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Submit report',
                  isLoading: submitting, // disabled while sending
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
