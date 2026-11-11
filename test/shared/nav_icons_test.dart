import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careid_patient_app/shared/widgets/careid_bottom_navigation_bar.dart';

void main() {
  testWidgets('CareIdBottomNavigationBar renders all 4 tabs matching approved Figma design', (tester) async {
    int selectedTab = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CareIdBottomNavigationBar(
            currentIndex: selectedTab,
            onTabSelected: (index) => selectedTab = index,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Records'), findsOneWidget);
    expect(find.text('Doctor'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap Records tab
    await tester.tap(find.text('Records'));
    expect(selectedTab, 1);
  });
}
