import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// One optional photo: take it with the camera or choose it from the gallery,
// see a preview, and remove it again. The parent screen keeps the File.
class PhotoPickerField extends StatelessWidget {
  final File? photo;
  final ValueChanged<File?> onChanged;
  final bool enabled;
  const PhotoPickerField({
    super.key,
    required this.photo,
    required this.onChanged,
    this.enabled = true,
  });

  Future<void> _pick(BuildContext context) async {
    // Ask where the photo should come from
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return; // closed without choosing
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70, // smaller file: faster upload, less storage
        maxWidth: 1280,
      );
      if (picked != null) onChanged(File(picked.path));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the camera or gallery.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return OutlinedButton.icon(
        onPressed: enabled ? () => _pick(context) : null,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add a photo (optional)'),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            photo!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filledTonal(
            tooltip: 'Remove photo',
            icon: const Icon(Icons.close),
            onPressed: enabled ? () => onChanged(null) : null,
          ),
        ),
      ],
    );
  }
}
