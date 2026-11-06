import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import '../services/storage_service.dart' show PhotoUploadException;

// Turns Firestore error codes into messages a user can understand.
// Works like auth_errors.dart, but for database errors.
// The code in brackets helps you find the cause while developing.
String friendlyFirestoreError(Object error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'The database refused access (permission-denied). '
            'Check the Firestore rules.';
      case 'unauthenticated':
        return 'Your session has expired. Please log in again.';
      case 'unavailable':
        return 'Cannot reach the database. Check your internet connection.';
      case 'deadline-exceeded':
        return 'The database took too long to answer. Please try again.';
      case 'not-found':
        return 'The database or report was not found (not-found).';
      case 'failed-precondition':
        return 'The database is not ready for this request '
            '(failed-precondition).';
      default:
        return 'Something went wrong (${error.code}). Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}

// The same idea for photo uploads to Cloudinary
String friendlyUploadError(Object error) {
  if (error is TimeoutException) {
    return 'The photo upload took too long. Check your connection and try again.';
  }
  if (error is SocketException) {
    return 'No internet connection, so the photo could not be uploaded.';
  }
  if (error is PhotoUploadException) {
    if (error.statusCode == 400 || error.statusCode == 401) {
      return 'The photo was refused: ${error.message}';
    }
    return 'Could not upload the photo (error ${error.statusCode}). '
        'Please try again.';
  }
  return 'Could not upload the photo. Please try again.';
}
