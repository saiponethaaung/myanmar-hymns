import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseModel extends ChangeNotifier {
  late SharedPreferences _sh;
  double _fontScale = 1.0;
  String _type = "";

  List<SongDTO> _songs = [];

  List<SongDTO> get songs => _songs;

  set songs(List<SongDTO> songs) {
    _songs = songs;
    notifyListeners();
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

  initData() async {
    _sh = await SharedPreferences.getInstance();

    double? scale = _sh.getDouble('fontScale');

    if (scale != null) {
      fontScale = scale;
    }
  }
}
