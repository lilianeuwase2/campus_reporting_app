import 'package:flutter_test/flutter_test.dart';

import 'package:campus_reporting_app/utils/roles.dart';

void main() {
  group('roleForEmail', () {
    test('ALU staff emails become staff', () {
      expect(roleForEmail('j.doe@alueducation.com'), 'staff');
    });

    test('ALU student emails become students', () {
      expect(roleForEmail('l.uwase@alustudent.com'), 'student');
    });

    test('ignores capital letters and spaces', () {
      expect(roleForEmail('  J.Doe@ALUEducation.com '), 'staff');
    });

    test('a look-alike domain is not staff', () {
      expect(roleForEmail('someone@fake-alueducation.com'), 'student');
    });
  });
}
