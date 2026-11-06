import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String? photoUrl;
  final String? photoPath; // the file's place in Storage
  final String reporterId;
  final String reporterName;
  final bool isAnonymous;
  final String? staffNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    this.photoUrl,
    this.photoPath,
    required this.reporterId,
    required this.reporterName,
    this.isAnonymous = false,
    this.staffNote,
    this.createdAt,
    this.updatedAt,
  });

  // Turns a Firestore document into an Incident object
  factory Incident.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Incident(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'other',
      location: data['location'] ?? '',
      status: data['status'] ?? 'submitted',
      photoUrl: data['photoUrl'],
      photoPath: data['photoPath'],
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? 'Unknown',
      isAnonymous: data['isAnonymous'] ?? false,
      staffNote: data['staffNote'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}