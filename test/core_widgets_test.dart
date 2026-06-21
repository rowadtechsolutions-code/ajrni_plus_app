import 'package:arini_plus_app/core/widgets/confirmation_dialog.dart';
import 'package:arini_plus_app/core/widgets/selection_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('selection bottom sheet filters cities using search', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showSelectionBottomSheet<String>(
              context: context,
              title: 'Choose city',
              items: const [
                SelectionItem(value: 'Muscat', label: 'Muscat'),
                SelectionItem(value: 'Salalah', label: 'Salalah'),
              ],
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Muscat'), findsOneWidget);
    expect(find.text('Salalah'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sala');
    await tester.pump();
    expect(find.text('Muscat'), findsNothing);
    expect(find.text('Salalah'), findsOneWidget);
  });

  testWidgets('confirmation dialog returns the selected action', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _testApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showConfirmationDialog(
                context: context,
                title: 'Delete account',
                message: 'This cannot be undone.',
                confirmText: 'Confirm',
                cancelText: 'Cancel',
                destructive: true,
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });
}
