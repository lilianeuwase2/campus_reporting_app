import 'package:flutter/material.dart';

// Only emails from these domains can register
const aluEmailDomains = ['alustudent.com', 'alueducation.com'];

// Firestore collection names
const usersCollection = 'users';
const incidentsCollection = 'incidents';
const updatesCollection = 'updates'; // status history, inside each incident

// Report statuses: the code saved in Firestore -> the label people see
const statusLabels = {
  'submitted': 'Submitted',
  'in_review': 'In review',
  'in_progress': 'In progress',
  'resolved': 'Resolved',
  'rejected': 'Rejected',
};

const statusColors = {
  'submitted': Colors.blueGrey,
  'in_review': Colors.orange,
  'in_progress': Colors.blue,
  'resolved': Colors.green,
  'rejected': Colors.red,
};

// Statuses that mean staff are finished with a report
const closedStatuses = ['resolved', 'rejected'];

// Report categories: the code saved in Firestore -> the label people see
const categoryLabels = {
  'facilities': 'Facilities',
  'water': 'Water',
  'electricity': 'Electricity',
  'furniture': 'Furniture',
  'sanitation': 'Sanitation',
  'safety': 'Safety & Security',
  'it': 'Internet / IT',
  'other': 'Other',
};

const categoryIcons = {
  'facilities': Icons.apartment,
  'water': Icons.water_drop,
  'electricity': Icons.bolt,
  'furniture': Icons.chair,
  'sanitation': Icons.cleaning_services,
  'safety': Icons.shield,
  'it': Icons.wifi,
  'other': Icons.help_outline,
};

// Cloudinary (photo storage). These two values are not secret: they only
// say WHERE to upload. The unsigned preset decides what uploads may do,
// and the secret key stays in the Cloudinary account, never in the app.
const cloudinaryCloudName = 'vekht7dk';
const cloudinaryUploadPreset = 'campus_reports';
