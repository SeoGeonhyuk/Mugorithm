import 'package:flutter/material.dart';
import 'package:mugorithm/model/music.dart';
import 'package:mugorithm/widgets/grid_music_item.dart';

class MyMusicGridView extends StatelessWidget {
  final List<Music> musicList;

  const MyMusicGridView({Key? key, required this.musicList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 17),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisExtent: 250,
          crossAxisSpacing: 0.0,
          mainAxisSpacing: 15.0,
        ),
        itemCount: musicList.length,
        itemBuilder: (context, index) {
          return GridMusicItem(music: musicList[index]);
        },
      ),
    );
  }
}
