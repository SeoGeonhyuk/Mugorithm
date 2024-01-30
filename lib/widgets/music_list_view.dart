import 'package:flutter/material.dart';
import 'package:mugorithm/model/music.dart';
import 'package:mugorithm/widgets/music_item.dart';

class MusicListView extends StatelessWidget {
  final List<Music> musicList;

  const MusicListView({Key? key, required this.musicList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black12,
          width: 2,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: musicList.map((music) {
            return MusicItem(
              //imageUrl: music.imageUrl,
              music: music,
            );
          }).toList(),
        ),
      ),
    );
  }
}
