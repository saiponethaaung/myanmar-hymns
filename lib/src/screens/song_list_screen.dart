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
  final TextEditingController _controller = TextEditingController();
  bool _showOnlyFavorites = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTitle() {
    if (_baseModel.type == "hymn") {
      return "ဓ္ဓမသီချင်း (Hymn)";
    } else if (_baseModel.type == "modern") {
      return "ခေတ်ပေါ် ဓ္ဓမသီချင်း (Modern Hymn)";
    } else if (_baseModel.type == "favorite") {
      return "အကြိုက်ဆုံးများ (Favorites)";
    }
    return "ဓ္ဓမသီချင်း";
  }

  @override
  Widget build(BuildContext context) {
    _baseModel = Provider.of<BaseModel>(context);
    final isFavoritesScreen = _baseModel.type == "favorite";

    final displayedSongs = _baseModel.songs
        .where((s) {
          if (isFavoritesScreen) {
            return _baseModel.isFavorite(s);
          }
          if (s.type != _baseModel.type) {
            return false;
          }
          if (_showOnlyFavorites && !_baseModel.isFavorite(s)) {
            return false;
          }
          return true;
        })
        .where((s) {
          if (_controller.text.isEmpty) {
            return true;
          }
          return s.title
              .toLowerCase()
              .contains(_controller.text.toLowerCase());
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (!isFavoritesScreen)
            IconButton(
              icon: Icon(
                _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                color: _showOnlyFavorites ? Colors.red : Colors.white,
              ),
              tooltip: _showOnlyFavorites
                  ? 'Show all songs'
                  : 'Show favorites only',
              onPressed: () {
                setState(() {
                  _showOnlyFavorites = !_showOnlyFavorites;
                });
              },
            ),
        ],
      ),
      body: ZoomWidget(
        SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: TextField(
                    autofocus: false,
                    controller: _controller,
                    style: TextStyle(fontSize: _baseModel.textFontSize),
                    decoration: InputDecoration(
                      hintText: "သီချင်း ရှာရန် (Search number or title)...",
                      hintStyle: const TextStyle(color: Colors.black45),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color.fromRGBO(210, 90, 0, 1),
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.black45),
                              tooltip: 'Clear search',
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.black12,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(255, 133, 27, 1),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            if (displayedSongs.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 60),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        (isFavoritesScreen || _showOnlyFavorites)
                                            ? Icons.favorite_border_rounded
                                            : Icons.search_off_rounded,
                                        size: 48,
                                        color: Colors.black38,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        (isFavoritesScreen || _showOnlyFavorites)
                                            ? "အကြိုက်ဆုံး သီချင်း မရှိသေးပါ\n(No favorite songs yet)"
                                            : "သီချင်း ရှာမတွေ့ပါ\n(No songs found)",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: _baseModel.textFontSize,
                                          color: Colors.black54,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 8,
                                  top: 4,
                                ),
                                child: Text(
                                  'စုစုပေါင်း ${displayedSongs.length} ပုဒ် (${displayedSongs.length} songs)',
                                  style: TextStyle(
                                    fontSize: _baseModel.textFontSize * 0.8,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ...displayedSongs.map((s) => SongRowWidget(s)),
                              const SizedBox(height: 60),
                            ],
                          ],
                        ),
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
