import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Favorite Song Tests', () {
    late BaseModel baseModel;
    late SongDTO song1;
    late SongDTO song2;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      baseModel = BaseModel();
      await baseModel.initData();

      song1 = SongDTO('၁ အိမ်ထောင်လုံးနံနက်သီချင်း။', 'hymn', 'Lyrics 1');
      song2 = SongDTO('ခံစားရ (၁)', 'modern', 'Lyrics 2');

      baseModel.songs = [song1, song2];
    });

    test('SongDTO generates unique key', () {
      expect(song1.key, equals('hymn:၁ အိမ်ထောင်လုံးနံနက်သီချင်း။'));
      expect(song2.key, equals('modern:ခံစားရ (၁)'));
    });

    test('Initial favorite state is false', () {
      expect(baseModel.isFavorite(song1), isFalse);
      expect(baseModel.isFavorite(song2), isFalse);
      expect(baseModel.favoriteSongs, isEmpty);
    });

    test('Toggle favorite adds and removes song', () async {
      bool notified = false;
      baseModel.addListener(() {
        notified = true;
      });

      // Add to favorites
      await baseModel.toggleFavorite(song1);
      expect(notified, isTrue);
      expect(baseModel.isFavorite(song1), isTrue);
      expect(baseModel.favoriteSongs.length, equals(1));
      expect(baseModel.favoriteSongs.first.title, equals(song1.title));

      // Remove from favorites
      notified = false;
      await baseModel.toggleFavorite(song1);
      expect(notified, isTrue);
      expect(baseModel.isFavorite(song1), isFalse);
      expect(baseModel.favoriteSongs, isEmpty);
    });

    test('Initializes favorites from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'favoriteSongs': ['hymn:၁ အိမ်ထောင်လုံးနံနက်သီချင်း။'],
      });

      final model = BaseModel();
      model.songs = [song1, song2];
      await model.initData();

      expect(model.isFavorite(song1), isTrue);
      expect(model.isFavorite(song2), isFalse);
      expect(model.favoriteSongs.length, equals(1));
    });
  });
}

