import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:myanmar_hymns/src/widget/song_row_widget.dart';
import 'package:myanmar_hymns/src/widget/zoom_widget.dart';
import 'package:provider/provider.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({
    super.key,
  });

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  late BaseModel _baseModel;
  TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    _baseModel = Provider.of<BaseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_baseModel.type == "hymn"
            ? "ဓ္ဓမသီချင်း (Hymn)"
            : "ခေတ်ပေါ် ဓ္ဓမသီချင်း (Modern Hymn)"),
      ),
      body: ZoomWidget(
        SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  autofocus: false,
                  decoration: const InputDecoration(
                    hintText: "Search",
                  ),
                  controller: _controller,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: SizedBox(
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ..._baseModel.songs
                              .where((s) => s.type == _baseModel.type)
                              .where((s) {
                            if (_controller.text.isEmpty) {
                              return true;
                            }

                            return s.title
                                .toLowerCase()
                                .contains(_controller.text.toLowerCase());
                          }).map((s) => SongRowWidget(s)),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
