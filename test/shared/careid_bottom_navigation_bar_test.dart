import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/shared/widgets/careid_bottom_navigation_bar.dart';

void main() {
  testWidgets('CareIdBottomNavigationBar rect and paint test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Container(color: Colors.red),
          bottomNavigationBar: CareIdBottomNavigationBar(
            currentIndex: 0,
            onTabSelected: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final navBarFinder = find.byType(CareIdBottomNavigationBar);
    expect(navBarFinder, findsOneWidget);
    final navBarRect = tester.getRect(navBarFinder);
    debugPrint('NavBar rect: $navBarRect');

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Records'), findsOneWidget);
    expect(find.text('Doctor'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
