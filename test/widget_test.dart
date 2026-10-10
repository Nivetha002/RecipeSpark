import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recime/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home selection reaches Select Ingredients screen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(RecipeSparkApp(prefs: prefs));
    expect(find.text('Quick Ingredients'), findsOneWidget);

    await tester.tap(find.text('Tomato'));
    await tester.pump();

    await tester.tap(find.text('View all').first);
    await tester.pumpAndSettle();

    expect(find.text('Select Ingredients'), findsOneWidget);
    expect(find.text('Find Recipes (1 selected)'), findsOneWidget);
  });
}
