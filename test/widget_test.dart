import 'package:flutter_test/flutter_test.dart';

import 'package:campus_reporting_app/utils/validators.dart';

// The app needs Firebase to start, so these tests check the validators only
void main() {
  test('rejects non-ALU emails', () {
    expect(validateAluEmail('someone@gmail.com'), isNotNull);
    expect(validateAluEmail('someone@alustudent.com'), isNull);
  });

  test('requires 8+ character passwords', () {
    expect(validatePassword('short'), isNotNull);
    expect(validatePassword('longenough'), isNull);
  });
}
