import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:myanmar_hymns/src/widget/song_row_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SongRowWidget displays song and toggles favorite',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final baseModel = BaseModel();
    await baseModel.initData();

    final song = SongDTO('Test Hymn', 'hymn', 'Lyrics content');
    baseModel.songs = [song];

    await tester.pumpWidget(
      ChangeNotifierProvider<BaseModel>.value(
        value: baseModel,
        child: MaterialApp(
          home: Scaffold(
            body: SongRowWidget(song),
          ),
        ),
      ),
    );

    // Initial state: outline heart
    expect(find.text('Test Hymn'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    // Tap favorite button
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    // Now favorited: filled heart
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(baseModel.isFavorite(song), isTrue);

    // Tap again to unfavorite
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(baseModel.isFavorite(song), isFalse);
  });
}
