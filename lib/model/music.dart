class Music {
  final String title;
  final String artist;
  final int id;
  String _videoLink = '';
  String _lyrics = '';

  bool _isLiked = false;
  double _rating = 0;

  bool get isLiked => _isLiked;

  double get rating => _rating;

  String get videoLink => _videoLink;

  String get lyrics => _lyrics;

  Music({
    required this.title,
    required this.artist,
    required this.id,
  });

  set isLiked(bool isLiked) {
    _isLiked = isLiked;
  }

  set rating(double rating) {
    _rating = rating;
  }

  set videoLink(String videoLink) {
    _videoLink = videoLink;
  }

  set lyrics(String lyrics) {
    _lyrics = lyrics;
  }

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      title: json['Title'] ?? '', // title이 없으면 공백으로 저장
      artist: json['Artist'] ?? '',
      id: json['ID'] ?? '',
    );
  }
}
