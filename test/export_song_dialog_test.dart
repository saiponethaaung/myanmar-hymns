import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:myanmar_hymns/src/widget/export_song_dialog.dart';

void main() {
  testWidgets('ExportSongDialog renders and has fixed-width export card',
      (WidgetTester tester) async {
    // Test on a realistic mobile viewport (iPhone 14/15/16: 390x844 logical pt)
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final song = SongDTO(
      '၁ အိမ်ထောင်လုံးနံနက်သီချင်း။',
      'ဓမ္မသီချင်း',
      '၁ လာကြလော့၊ အိမ်သူအိမ်သားများ၊\nကျေးဇူးတော်အောက်မေ့ကြစို့။\n\n'
          '၂ ကောင်းကင်ဘုံ၊ မြေကြီးအာရုံ\nဖန်ဆင်းသောဘုရားအရှင်၊',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExportSongDialog(
            song: song,
            fontScale: 1.0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify dialog header is present
    expect(find.text('Export Song Card'), findsOneWidget);
    expect(find.text('Share Image'), findsOneWidget);
    expect(find.text('Save Image'), findsOneWidget);
    expect(find.text('Copy'), findsNothing);

    // Verify the offscreen export container has width 720.0
    final offscreenFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color ==
              const Color.fromRGBO(246, 239, 209, 1),
    );

    // We have preview card and offscreen card
    expect(offscreenFinder, findsWidgets);

    // Find the RepaintBoundary with the 720px width export card
    final repaintBoundaries = tester.renderObjectList<RenderRepaintBoundary>(
      find.byType(RepaintBoundary),
    );

    // At least one RenderRepaintBoundary should be the export card at 720.0 width
    final exportBoundary = repaintBoundaries.firstWhere(
      (b) => b.size.width == 720.0,
    );
    expect(exportBoundary.size.width, equals(720.0));

    // Capture image from export boundary
    final ui.Image image = await exportBoundary.toImage(pixelRatio: 2.0);
    expect(image.width, equals(1440));
    expect(image.height, greaterThan(200));
  });
}
