import 'package:intl/intl.dart';

// Small helpers that turn data into text or links for the screen.
// They are plain functions (no widgets), so they are easy to test.

// Turns a date into friendly text like "2 hours ago", as in the sample design.
// Tests pass in "now" so the answer is always the same.
String timeAgo(DateTime? time, {DateTime? now}) {
  // A new report has no server time for a moment, right after it is sent
  if (time == null) return 'Just now';
  final diff = (now ?? DateTime.now()).difference(time);

  // Less than a minute ago, or the phone clock is a little ahead of the server
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return _ago(diff.inMinutes, 'minute');
  if (diff.inDays < 1) return _ago(diff.inHours, 'hour');
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  // Older than a week: show the date itself, e.g. "3 Nov 2026"
  return DateFormat('d MMM yyyy').format(time);
}

// "1 hour ago" but "2 hours ago"
String _ago(int n, String unit) => '$n $unit${n == 1 ? '' : 's'} ago';

// Cloudinary can resize a photo when it is downloaded: adding
// "c_fill,w_200,h_200" to the link gives a small square copy.
// Report cards use it, so lists load faster and use less mobile data.
// Links that are not Cloudinary photos come back unchanged.
String smallPhotoUrl(String url) {
  const marker = '/image/upload/';
  if (!url.contains('res.cloudinary.com') || !url.contains(marker)) return url;
  return url.replaceFirst(marker, '${marker}c_fill,w_200,h_200,q_auto/');
}
