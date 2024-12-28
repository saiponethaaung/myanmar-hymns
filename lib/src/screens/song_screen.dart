import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:myanmar_hymns/src/widget/zoom_widget.dart';
import 'package:provider/provider.dart';

class SongScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  late BaseModel baseModel;
  late SongDTO song;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    song = ModalRoute.of(context)!.settings.arguments as SongDTO;
    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
      ),
      body: ZoomWidget(
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 50,
              ),
              child: Column(
                children: [
                  SelectableText.rich(
                    TextSpan(
                      children: song.content
                          .split("\n")
                          .map(
                            (s) => TextSpan(
                              text: s.trim() + "\n",
                              style: TextStyle(
                                fontSize: baseModel.textFontSize,
                                height: 1.8,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
