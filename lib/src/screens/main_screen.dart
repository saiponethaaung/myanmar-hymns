import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:myanmar_hymns/src/widget/song_row_widget.dart';
import 'package:myanmar_hymns/src/widget/zoom_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late BaseModel _baseModel;

  void openWebsite() async {
    Uri url = Uri.parse("https://placeinheart.com");

    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    _baseModel = Provider.of<BaseModel>(context);

    return Scaffold(
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  child: Image.asset('assets/logo/main-logo.png'),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/about');
                        },
                        child: const Text('About'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () => openWebsite(),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(30),
                child: const Text(
                  '❤️ by Place in Heart ❤️',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Myanmar Hymns"),
      ),
      body: ZoomWidget(
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                  onTap: () {
                    _baseModel.type = 'hymn';
                    Navigator.pushNamed(context, '/song-list');
                  },
                  child: Text(
                    'ဓ္ဓမသီချင်း (Hymn)',
                    style: TextStyle(
                      fontSize: _baseModel.textFontSize,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    _baseModel.type = 'modern';
                    Navigator.pushNamed(context, '/song-list');
                  },
                  child: Text(
                    'ခေတ်ပေါ် ဓ္ဓမသီချင်း (Modern Hymn)',
                    style: TextStyle(
                      fontSize: _baseModel.textFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
