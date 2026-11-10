class SongDTO {
  String title;
  String type;
  String content;
  String? id;

  SongDTO(this.title, this.type, this.content, [this.id]);

  String get key => '$type:$title';

  String get formattedContent =>
      content.split('\n').map((s) => s.trim()).join('\n');
}

