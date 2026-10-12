import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quron_app/main.dart';

void main() {
  testWidgets('QuronApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuronApp());

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
