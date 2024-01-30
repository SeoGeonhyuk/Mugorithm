import 'package:flutter/material.dart';
import 'package:mugorithm/model/User.dart';
import 'package:mugorithm/page/my_music_page.dart';
import 'package:mugorithm/providers/music_provider.dart';
import 'package:mugorithm/providers/user_provider.dart';
import 'package:mugorithm/widgets/music_list_view.dart';
import 'package:provider/provider.dart';

class AllMusicPage extends StatefulWidget {
  const AllMusicPage({Key? key}) : super(key: key);

  @override
  State<AllMusicPage> createState() => _AllMusicPageState();
}

class _AllMusicPageState extends State<AllMusicPage> {
  late Future<void> fetchDataFuture;

  @override
  void initState() {
    super.initState();
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    //print("올 뮤직 페이지 initstate전\n");
    // 비동기 데이터 로딩을 시작
    fetchDataFuture = _fetchDataSequentially(musicProvider, userProvider.user!);
    //print("올 뮤직 페이지 initstate완료\n");
  }

  Future<List<void>> _fetchDataSequentially(
      // allMusicLsit부터 비동기로 갖고와서 myMusicList
      MusicProvider musicProvider,
      User user) async {
    await musicProvider.fetchAllMusicList(user);
    await musicProvider.fetchRecommendMusicList(user);
    return await musicProvider.fetchMymusicList(user);
  }

  @override
  Widget build(BuildContext context) {
    //print('all music\n');
    final musicProvider = Provider.of<MusicProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FutureBuilder(
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      '뮤직 리스트',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  MusicListView(musicList: musicProvider.allMusicList),
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      '추천 뮤직 리스트',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  MusicListView(musicList: musicProvider.recommendMusicList),
                ],
              );
            }
          },
        ),
      ],
    ));
  }
}
