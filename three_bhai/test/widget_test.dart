import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_bhai/core/widgets/gradient_button.dart';

void main() {
  testWidgets('GradientButton shows a spinner while loading', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GradientButton(label: 'Log in', onPressed: () {}, isLoading: true),
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
  });

  testWidgets('GradientButton shows its label and reacts to taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GradientButton(label: 'Log in', onPressed: () => taps++),
      ),
    ));
    expect(find.text('Log in'), findsOneWidget);
    await tester.tap(find.text('Log in'));
    expect(taps, 1);
  });
}
