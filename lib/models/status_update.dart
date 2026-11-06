import 'package:cloud_firestore/cloud_firestore.dart';

// One entry in a report's history. Staff create one each time they change
// a report's status, so students can follow its progress.
class StatusUpdate {
  final String id;
  final String status;
  final String note;
  final String updatedByName;
  final DateTime? updatedAt;

  StatusUpdate({
    required this.id,
    required this.status,
    required this.note,
    required this.updatedByName,
    this.updatedAt,
  });

  // Turns a Firestore document into a StatusUpdate object
  factory StatusUpdate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return StatusUpdate(
      id: doc.id,
      status: data['status'] ?? 'submitted',
      note: data['note'] ?? '',
      updatedByName: data['updatedByName'] ?? 'Staff',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
