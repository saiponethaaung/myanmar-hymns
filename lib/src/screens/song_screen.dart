import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:myanmar_hymns/src/widget/export_song_dialog.dart';
import 'package:myanmar_hymns/src/widget/zoom_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({super.key});

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

  Future<void> _openYouTube(BuildContext context, String title) async {
    final cleanTitle = title.replaceAll('။', '').trim();
    final query =
        cleanTitle.contains('သီချင်း') ? cleanTitle : '$cleanTitle ဓမ္မသီချင်း';
    final uri = Uri.parse(
      'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open YouTube: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    baseModel = Provider.of<BaseModel>(context);
    song = ModalRoute.of(context)!.settings.arguments as SongDTO;
    final isFav = baseModel.isFavorite(song);

    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_display_rounded, color: Colors.white),
            tooltip: 'Search on YouTube',
            onPressed: () => _openYouTube(context, song.title),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Colors.white),
            tooltip: 'Copy Lyrics',
            onPressed: () async {
              final textToCopy =
                  '${song.title}\n\n${song.formattedContent}\n\n— Myanmar Hymns (placeinheart.com)';
              await Clipboard.setData(ClipboardData(text: textToCopy));
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'သီချင်းစာသား ကူးယူပြီးပါပြီ (Lyrics copied to clipboard)',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Export Image / Share',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ExportSongDialog(
                  song: song,
                  fontScale: baseModel.fontScale,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white,
            ),
            tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () {
              baseModel.toggleFavorite(song);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !isFav
                        ? 'Added to favorites'
                        : 'Removed from favorites',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: ZoomWidget(
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          fontSize: baseModel.textFontSize * 1.25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 2,
                        width: 60,
                        color: const Color.fromRGBO(255, 133, 27, 1),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _openYouTube(context, song.title),
                          icon: const Icon(
                            Icons.smart_display_rounded,
                            color: Colors.red,
                            size: 22,
                          ),
                          label: const Text(
                            'YouTube တွင် ရှာဖွေနားဆင်ရန်',
                            style: TextStyle(
                              color: Color.fromRGBO(190, 40, 20, 1),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            backgroundColor:
                                const Color.fromRGBO(255, 235, 235, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SelectableText.rich(
                        TextSpan(
                          children: song.formattedContent
                              .split("\n")
                              .map(
                                (s) => TextSpan(
                                  text: '$s\n',
                                  style: TextStyle(
                                    fontSize: baseModel.textFontSize,
                                    height: 1.9,
                                    color: Colors.black87,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
