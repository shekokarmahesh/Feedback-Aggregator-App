import 'package:feedback_aggregator_flutter/widgets/mascot.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpMascot(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Mascot(
            directions: 'assets/mascots/postbot-directions.webp',
            reactions: 'assets/mascots/postbot-reactions.webp',
          ),
        ),
      ),
    ),
  );

  // Layer 0 is the directions sheet, layer 1 the reactions sheet.
  ({Alignment cell, bool visible}) sheet(WidgetTester tester, int layer) {
    final opacity = find
        .descendant(of: find.byType(Mascot), matching: find.byType(Opacity))
        .at(layer);
    final box = tester.widget<OverflowBox>(
      find.descendant(of: opacity, matching: find.byType(OverflowBox)),
    );
    return (
      cell: box.alignment as Alignment,
      visible: tester.widget<Opacity>(opacity).opacity == 1,
    );
  }

  testWidgets('head follows the mouse and ignores touch', (tester) async {
    await pumpMascot(tester);
    final center = tester.getCenter(find.byType(Mascot));

    final touch = await tester.startGesture(
      center + const Offset(200, 0),
      kind: PointerDeviceKind.touch,
    );
    await touch.moveBy(const Offset(0, 100));
    await touch.up();
    await tester.pump();
    expect(sheet(tester, 0).cell, Alignment.center);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: center);
    addTearDown(mouse.removePointer);

    await mouse.moveTo(center + const Offset(200, 0));
    await tester.pump();
    expect(sheet(tester, 0).cell, const Alignment(1, 0));

    await mouse.moveTo(center + const Offset(-150, -150));
    await tester.pump();
    expect(sheet(tester, 0).cell, const Alignment(-1, -1));

    await mouse.moveTo(center + const Offset(10, 10));
    await tester.pump();
    expect(sheet(tester, 0).cell, Alignment.center);
  });

  testWidgets('a tap blinks, pays off, then settles back', (tester) async {
    await pumpMascot(tester);

    await tester.tap(find.byType(Mascot));
    await tester.pump();
    expect(sheet(tester, 0).visible, isFalse);
    expect(sheet(tester, 1), (cell: const Alignment(-1, -1), visible: true));

    await tester.pump(const Duration(milliseconds: 150));
    expect(sheet(tester, 1).cell, const Alignment(0, -1));

    await tester.pump(const Duration(milliseconds: 500));
    expect(sheet(tester, 0).visible, isTrue);
    expect(sheet(tester, 1).visible, isFalse);
  });

  testWidgets('four quick taps make it dizzy', (tester) async {
    await pumpMascot(tester);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byType(Mascot));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(sheet(tester, 1), (cell: const Alignment(0, 1), visible: true));

    await tester.pump(const Duration(milliseconds: 1200));
    expect(sheet(tester, 1).visible, isFalse);
  });
}
