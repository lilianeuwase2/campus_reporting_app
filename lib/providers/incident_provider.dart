import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/incident.dart';
import '../models/status_update.dart';
import '../services/incident_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/firestore_errors.dart';
import '../utils/incident_filters.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service;
  final StorageService _storage;
  StreamSubscription<List<Incident>>? _sub;

  List<Incident> _all = [];
  String? _myUid; // who is logged in, for "My reports"
  bool isLoading = true;
  bool isSubmitting = false;
  bool isUpdatingStatus = false;
  String? loadError;
  String searchQuery = '';
  String? statusFilter; // null means "all"
  String? categoryFilter; // null means "all"

  IncidentProvider(this._service, this._storage);

  // Called once by MainShell after login
  void startListening(String uid) {
    _myUid = uid;
    _sub ??= _service.watchIncidents().listen(
      (list) {
        _all = list;
        isLoading = false;
        loadError = null;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Loading reports failed: $error'); // full details in the terminal
        isLoading = false;
        loadError = friendlyFirestoreError(error);
        notifyListeners();
      },
    );
  }

  // Try again after an error, e.g. once the rules are fixed or Wi-Fi is back
  void retry() {
    final uid = _myUid;
    if (uid == null) return;
    _sub?.cancel();
    _sub = null;
    isLoading = true;
    loadError = null;
    notifyListeners();
    startListening(uid);
  }

  // Called on logout, so the next user starts clean
  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _all = [];
    _myUid = null;
    isLoading = true;
    loadError = null;
    searchQuery = '';
    statusFilter = null;
    categoryFilter = null;
  }

  bool get isFiltering =>
      searchQuery.isNotEmpty || statusFilter != null || categoryFilter != null;

  // The list the screen shows: reports matching the search AND every filter
  List<Incident> get filtered => _all
      .where(
        (i) => matchesFilters(
          i,
          query: searchQuery,
          status: statusFilter,
          category: categoryFilter,
        ),
      )
      .toList();

  // Every report, newest first, for the Home tab
  List<Incident> get all => List.unmodifiable(_all);

  // Only the reports the logged-in user sent, for the "My reports" tab
  List<Incident> get myIncidents =>
      _all.where((i) => i.reporterId == _myUid).toList();

  // How many reports have each status, e.g. {'submitted': 3, 'resolved': 5}
  Map<String, int> get statusCounts {
    final counts = {for (final s in statusLabels.keys) s: 0};
    for (final i in _all) {
      counts[i.status] = (counts[i.status] ?? 0) + 1;
    }
    return counts;
  }

  // Reports staff still need to act on, oldest first so nothing waits too long
  List<Incident> get openIncidents {
    final now = DateTime.now(); // reports still saving have no date yet
    return _all.where((i) => !closedStatuses.contains(i.status)).toList()
      ..sort((a, b) => (a.createdAt ?? now).compareTo(b.createdAt ?? now));
  }

  void setSearch(String text) {
    searchQuery = text;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    statusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    categoryFilter = category;
    notifyListeners();
  }

  // The details screen listens to one report and its history through here
  Stream<Incident?> watchIncident(String id) => _service.watchIncident(id);
  Stream<List<StatusUpdate>> watchUpdates(String id) =>
      _service.watchUpdates(id);

  // Returns null if it worked, or an error message to show
  Future<String?> submitIncident({
    required String title,
    required String description,
    required String category,
    required String location,
    required bool anonymous,
    required String uid,
    required String name,
    File? photo, // optional
  }) async {
    isSubmitting = true;
    notifyListeners();
    try {
      // Upload the photo FIRST: the report needs the photo's link
      String? photoUrl;
      String? photoPath;
      if (photo != null) {
        try {
          final uploaded = await _storage.uploadIncidentPhoto(photo, uid);
          photoUrl = uploaded.url;
          photoPath = uploaded.path;
        } catch (e) {
          debugPrint('Photo upload failed: $e');
          return friendlyUploadError(e); // nothing is saved without the photo
        }
      }
      await _service.createIncident({
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'location': location.trim(),
        'photoUrl': photoUrl,
        'photoPath': photoPath, // the photo's id on Cloudinary
        'reporterId': uid,
        'reporterName': anonymous ? 'Anonymous' : name,
        'isAnonymous': anonymous,
      });
      return null;
    } catch (e) {
      debugPrint('Submitting report failed: $e');
      return friendlyFirestoreError(e);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // Staff only. Returns null if it worked, or an error message to show
  Future<String?> updateStatus({
    required Incident incident,
    required String newStatus,
    required String note,
    required String staffUid,
    required String staffName,
  }) async {
    isUpdatingStatus = true;
    notifyListeners();
    try {
      await _service.updateStatus(
        incidentId: incident.id,
        newStatus: newStatus,
        note: note.trim(),
        staffUid: staffUid,
        staffName: staffName,
      );
      return null;
    } catch (e) {
      debugPrint('Updating status failed: $e');
      return friendlyFirestoreError(e);
    } finally {
      isUpdatingStatus = false;
      notifyListeners();
    }
  }

  // Returns null if it worked, or an error message to show
  Future<String?> deleteIncident(Incident incident) async {
    try {
      await _service.deleteIncident(incident.id);
      // The photo stays on Cloudinary: deleting it needs the account's secret
      // key, and a secret key must never be inside an app
      return null;
    } catch (e) {
      debugPrint('Deleting report failed: $e');
      return friendlyFirestoreError(e);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
