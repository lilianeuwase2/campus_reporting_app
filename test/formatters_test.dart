import 'package:flutter_test/flutter_test.dart';

import 'package:campus_reporting_app/utils/formatters.dart';

void main() {
  // A fixed "now", so these tests give the same answer on any day
  final now = DateTime(2026, 11, 6, 12, 0);
  DateTime ago(Duration d) => now.subtract(d);

  group('timeAgo', () {
    test('a report that is still saving says Just now', () {
      expect(timeAgo(null, now: now), 'Just now');
    });

    test('less than a minute says Just now', () {
      expect(timeAgo(ago(const Duration(seconds: 30)), now: now), 'Just now');
    });

    test('minutes and hours use one and many correctly', () {
      expect(timeAgo(ago(const Duration(minutes: 1)), now: now), '1 minute ago');
      expect(timeAgo(ago(const Duration(minutes: 5)), now: now), '5 minutes ago');
      expect(timeAgo(ago(const Duration(hours: 1)), now: now), '1 hour ago');
      expect(timeAgo(ago(const Duration(hours: 2)), now: now), '2 hours ago');
    });

    test('days', () {
      expect(timeAgo(ago(const Duration(days: 1)), now: now), 'Yesterday');
      expect(timeAgo(ago(const Duration(days: 3)), now: now), '3 days ago');
    });

    test('older than a week shows the date', () {
      expect(timeAgo(DateTime(2026, 10, 2, 9), now: now), '2 Oct 2026');
    });

    test('a phone clock a little ahead never shows a negative time', () {
      expect(timeAgo(now.add(const Duration(minutes: 2)), now: now), 'Just now');
    });
  });

  group('smallPhotoUrl', () {
    test('asks Cloudinary for a small square copy', () {
      expect(
        smallPhotoUrl(
          'https://res.cloudinary.com/vekht7dk/image/upload/v1/abc.jpg',
        ),
        'https://res.cloudinary.com/vekht7dk/image/upload/'
        'c_fill,w_200,h_200,q_auto/v1/abc.jpg',
      );
    });

    test('leaves other links unchanged', () {
      const other = 'https://example.com/photo.jpg';
      expect(smallPhotoUrl(other), other);
    });
  });
}
