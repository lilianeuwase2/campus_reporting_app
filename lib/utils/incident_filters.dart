import '../models/incident.dart';

// Decides whether one report matches the search text and the filters.
// It is a plain function (no Firebase, no widgets), so it is easy to unit test.
// A filter that is null means "don't filter by this".
bool matchesFilters(
  Incident incident, {
  String query = '',
  String? status,
  String? category,
  String? reporterId,
}) {
  final q = query.trim().toLowerCase();
  final matchesSearch =
      q.isEmpty ||
      incident.title.toLowerCase().contains(q) ||
      incident.description.toLowerCase().contains(q) ||
      incident.location.toLowerCase().contains(q);
  final matchesStatus = status == null || incident.status == status;
  final matchesCategory = category == null || incident.category == category;
  final matchesReporter =
      reporterId == null || incident.reporterId == reporterId;
  return matchesSearch && matchesStatus && matchesCategory && matchesReporter;
}
