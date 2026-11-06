import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

// Thrown when Cloudinary refuses an upload, with the reason it gave
class PhotoUploadException implements Exception {
  final int statusCode;
  final String message;
  PhotoUploadException(this.statusCode, this.message);

  @override
  String toString() => 'PhotoUploadException($statusCode): $message';
}

// All the photo-file calls live here. Photos are stored on Cloudinary, a free
// image hosting service. The upload uses an "unsigned upload preset", so the
// app never contains Cloudinary's secret key.
class StorageService {
  static final _uploadUrl = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload',
  );

  // Uploads a photo and returns its web link (url) and its Cloudinary id (path)
  Future<({String url, String path})> uploadIncidentPhoto(
    File photo,
    String uid,
  ) async {
    // A "multipart" request is how a file is sent over the internet,
    // the same way a website form uploads a file
    final request = http.MultipartRequest('POST', _uploadUrl)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      // Tag each photo with who uploaded it, so misuse can be traced
      ..fields['tags'] = 'incident,reporter_$uid'
      ..files.add(await http.MultipartFile.fromPath('file', photo.path));

    // Give up after 45 seconds instead of spinning forever
    final response = await http.Response.fromStream(
      await request.send().timeout(const Duration(seconds: 45)),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final error = body['error'] as Map<String, dynamic>?;
      throw PhotoUploadException(
        response.statusCode,
        error?['message'] as String? ?? 'Upload failed',
      );
    }
    return (
      url: body['secure_url'] as String, // the https link the app shows
      path: body['public_id'] as String, // the photo's id on Cloudinary
    );
  }
}
