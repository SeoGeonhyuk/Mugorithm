import 'package:flutter/material.dart';
import 'package:mugorithm/model/User.dart';
import 'package:mugorithm/providers/music_provider.dart';
import 'package:mugorithm/providers/user_provider.dart';
import 'package:mugorithm/widgets/my_music_gridview.dart';
import 'package:provider/provider.dart';

class MyMusicPage extends StatefulWidget {
  const MyMusicPage({Key? key}) : super(key: key);

  @override
  State<MyMusicPage> createState() => _MyMusicPageState();
}

class _MyMusicPageState extends State<MyMusicPage> {
  late Future<void> fetchDataFuture;

  @override
  void initState() {
    super.initState();
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 비동기 데이터 로딩을 시작
    fetchDataFuture = musicProvider.fetchMymusicList(userProvider.user!);
  }

  @override
  Widget build(BuildContext context) {
    //print('my music\n');

    final musicProvider = Provider.of<MusicProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터를 로딩 중인 경우 CircularProgressIndicator() 표시
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // 에러가 발생한 경우 에러 메시지 표시
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // 데이터가 로드되었을 때 UI 표시
            return MyMusicGridView(musicList: musicProvider.myMusicList);
          }
        },
      ),
    );
  }
}
