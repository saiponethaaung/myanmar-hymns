import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseModel extends ChangeNotifier {
  late SharedPreferences _sh;
  double _fontScale = 1.0;
  String _type = "";

  List<SongDTO> _songs = [];
  Set<String> _favoriteSongKeys = {};

  List<SongDTO> get songs => _songs;

  set songs(List<SongDTO> songs) {
    _songs = songs;
    notifyListeners();
  }

  Set<String> get favoriteSongKeys => _favoriteSongKeys;

  List<SongDTO> get favoriteSongs =>
      _songs.where((song) => isFavorite(song)).toList();

  bool isFavorite(SongDTO song) {
    return _favoriteSongKeys.contains(song.key) ||
        _favoriteSongKeys.contains(song.title);
  }

  Future<void> toggleFavorite(SongDTO song) async {
    if (isFavorite(song)) {
      _favoriteSongKeys.remove(song.key);
      _favoriteSongKeys.remove(song.title);
    } else {
      _favoriteSongKeys.add(song.key);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    _sh = await SharedPreferences.getInstance();
    await _sh.setStringList('favoriteSongs', _favoriteSongKeys.toList());
  }

  double get fontScale => _fontScale;

  set fontScale(double value) {
    _fontScale = value;
    _sh.setDouble('fontScale', value);
    notifyListeners();
  }

  double get textFontSize => 16 * fontScale;

  String get type => _type;

  set type(String value) {
    _type = value;
    notifyListeners();
  }

  Future<void> initData() async {
    _sh = await SharedPreferences.getInstance();

    double? scale = _sh.getDouble('fontScale');

    if (scale != null) {
      _fontScale = scale;
    }

    List<String>? favs = _sh.getStringList('favoriteSongs');
    if (favs != null) {
      _favoriteSongKeys = favs.toSet();
    }

    notifyListeners();
  }
}
