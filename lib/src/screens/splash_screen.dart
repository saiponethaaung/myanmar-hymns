import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:myanmar_hymns/src/widget/main_screen_widget.dart';
import 'package:myanmar_hymns/src/widget/song_row_widget.dart';
import 'package:myanmar_hymns/src/widget/zoom_widget.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title});

  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late BaseModel _baseModel;
  String xmlAsString = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      parseXML();
      _baseModel.initData();
    });
  }

  void parseXML() async {
    final hymnsXmlString =
        await rootBundle.loadString('assets/songs/hymns.xml');
    final hymnsDocument = XmlDocument.parse(hymnsXmlString);
    final hymns = hymnsDocument.findAllElements('publication');
    for (var h in hymns) {
      _baseModel.songs.add(
        SongDTO(
          h.findElements('title').single.innerText.trim(),
          "hymn",
          h.findElements('publisher').single.innerText.trim(),
        ),
      );
    }

    final modernXmlString =
        await rootBundle.loadString('assets/songs/modern.xml');
    final modernDocument = XmlDocument.parse(modernXmlString);
    final modern = modernDocument.findAllElements('publication');
    for (var m in modern) {
      _baseModel.songs.add(
        SongDTO(
          m.findElements('title').single.innerText.trim(),
          "modern",
          m.findElements('publisher').single.innerText.trim(),
        ),
      );
    }

    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    _baseModel = Provider.of<BaseModel>(context);

    return Scaffold(
      body: MainScreenWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/main-logo.png',
              width: 180,
            )
          ],
        ),
      ),
    );
    ;
  }
}
