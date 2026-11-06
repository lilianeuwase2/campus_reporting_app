import 'package:flutter_test/flutter_test.dart';

import 'package:campus_reporting_app/models/incident.dart';
import 'package:campus_reporting_app/utils/incident_filters.dart';

// Makes a test report; change only the fields a test cares about
Incident makeReport({
  String title = 'No water in Block B',
  String status = 'submitted',
  String category = 'water',
  String reporterId = 'student-1',
}) {
  return Incident(
    id: 'test-id',
    title: title,
    description: 'The showers have had no water since this morning',
    category: category,
    location: 'Block B, 2nd floor',
    status: status,
    reporterId: reporterId,
    reporterName: 'Test Student',
  );
}

void main() {
  group('matchesFilters', () {
    test('keeps every report when no search or filters are set', () {
      expect(matchesFilters(makeReport()), isTrue);
    });

    test('search ignores capital letters', () {
      expect(matchesFilters(makeReport(), query: 'WATER'), isTrue);
    });

    test('search also looks at the location', () {
      expect(matchesFilters(makeReport(), query: '2nd floor'), isTrue);
    });

    test('hides a report when the search does not match', () {
      expect(matchesFilters(makeReport(), query: 'wifi'), isFalse);
    });

    test('status filter keeps only that status', () {
      expect(
        matchesFilters(makeReport(status: 'resolved'), status: 'resolved'),
        isTrue,
      );
      expect(
        matchesFilters(makeReport(status: 'submitted'), status: 'resolved'),
        isFalse,
      );
    });

    test('category filter keeps only that category', () {
      expect(
        matchesFilters(makeReport(category: 'water'), category: 'water'),
        isTrue,
      );
      expect(
        matchesFilters(makeReport(category: 'it'), category: 'water'),
        isFalse,
      );
    });

    test('Mine filter keeps only my reports', () {
      expect(
        matchesFilters(makeReport(reporterId: 'me'), reporterId: 'me'),
        isTrue,
      );
      expect(
        matchesFilters(makeReport(reporterId: 'someone-else'), reporterId: 'me'),
        isFalse,
      );
    });

    test('search and filters must ALL match', () {
      expect(
        matchesFilters(
          makeReport(status: 'submitted'),
          query: 'water',
          status: 'resolved',
        ),
        isFalse,
      );
    });
  });
}
