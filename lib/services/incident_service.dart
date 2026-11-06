import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../models/status_update.dart';
import '../utils/constants.dart';

// All the Firestore calls for incident reports live here
class IncidentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection(incidentsCollection);

  // Each report keeps its status history in its own "updates" subcollection
  CollectionReference<Map<String, dynamic>> _updatesOf(String incidentId) =>
      _incidents.doc(incidentId).collection(updatesCollection);

  // Live list, newest first. Sends a new list every time ANY report changes.
  Stream<List<Incident>> watchIncidents() => _incidents
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Incident.fromFirestore).toList());

  // Live view of ONE report. Sends null if the report was deleted.
  Stream<Incident?> watchIncident(String id) => _incidents
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? Incident.fromFirestore(doc) : null);

  // Live status history of one report, oldest first
  Stream<List<StatusUpdate>> watchUpdates(String incidentId) =>
      _updatesOf(incidentId)
          .orderBy('updatedAt')
          .snapshots()
          .map((snap) => snap.docs.map(StatusUpdate.fromFirestore).toList());

  Future<void> createIncident(Map<String, dynamic> data) => _incidents.add({
    ...data, // copy all the fields passed in
    'status': 'submitted',
    'staffNote': null,
    'createdAt': FieldValue.serverTimestamp(), // Google's clock, not the phone's
    'updatedAt': FieldValue.serverTimestamp(),
  });

  // Staff only: changes the status AND writes a history entry.
  // A batch makes both writes succeed together or fail together,
  // so the history can never disagree with the report.
  Future<void> updateStatus({
    required String incidentId,
    required String newStatus,
    required String note,
    required String staffUid,
    required String staffName,
  }) {
    final batch = _db.batch();
    batch.update(_incidents.doc(incidentId), {
      'status': newStatus,
      // Only replace the note shown to the student when staff wrote a new one
      if (note.isNotEmpty) 'staffNote': note,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_updatesOf(incidentId).doc(), {
      'status': newStatus,
      'note': note,
      'updatedBy': staffUid,
      'updatedByName': staffName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return batch.commit();
  }

  Future<void> deleteIncident(String id) => _incidents.doc(id).delete();
}
