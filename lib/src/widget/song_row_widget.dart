import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SongRowWidget extends StatelessWidget {
  late BaseModel baseModel;
  SongDTO song;

  SongRowWidget(this.song, {super.key});

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/song', arguments: song);
        },
        child: Text(
          song.title,
          style: TextStyle(fontSize: baseModel.textFontSize),
        ),
      ),
    );
  }
}
