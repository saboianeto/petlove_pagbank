import 'package:flutter_test/flutter_test.dart';

import 'package:petlove_pagbank/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PetlovePOSApp());

    // Wait for animations and navigation
    await tester.pumpAndSettle();

    // Verify that the home screen appears (check for COBRAR button)
    expect(find.text('COBRAR'), findsOneWidget);
  });
}
