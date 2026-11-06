import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_reporting_app/widgets/status_chip.dart';

void main() {
  testWidgets('StatusChip shows a readable label, not the code', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusChip(status: 'in_progress')),
      ),
    );
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('in_progress'), findsNothing);
  });

  testWidgets('StatusChip shows the raw code for an unknown status', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatusChip(status: 'archived'))),
    );
    expect(find.text('archived'), findsOneWidget);
  });
}
