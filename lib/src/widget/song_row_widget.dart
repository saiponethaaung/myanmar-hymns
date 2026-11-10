import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/dto/song_dto.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:provider/provider.dart';

class SongRowWidget extends StatelessWidget {
  final SongDTO song;

  const SongRowWidget(this.song, {super.key});

  @override
  Widget build(BuildContext context) {
    final baseModel = Provider.of<BaseModel>(context);
    final isFav = baseModel.isFavorite(song);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/song', arguments: song);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    song.title,
                    style: TextStyle(
                      fontSize: baseModel.textFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey[400],
                    size: 24,
                  ),
                  tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                  onPressed: () {
                    baseModel.toggleFavorite(song);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
