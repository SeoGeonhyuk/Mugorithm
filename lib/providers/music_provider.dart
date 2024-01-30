import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mugorithm/model/User.dart';
import 'package:mugorithm/model/music.dart';
import 'package:http/http.dart' as http;
import 'package:mugorithm/providers/user_provider.dart';

class MusicProvider extends ChangeNotifier {
  List<Music> _allMusicList = [];

  List<Music> _myMusicList = [];

  List<Music> _recommendMusicList = [];

  List<Music> get allMusicList => _allMusicList;

  List<Music> get myMusicList => _myMusicList;

  List<Music> get recommendMusicList => _recommendMusicList;

  final String _localhost = '192.168.0.2';

  // 모든 음악 리스트 가져오는 함수
  Future<List> fetchAllMusicList(User user) async {
    print('모든 음악 패치 실행');
    final String _allMusicListApi = 'http://${_localhost}:8080/musics';
    // 실제 동작 부분
    try {
      final response = await http.get(Uri.parse(_allMusicListApi));
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allMusicList = data.map((json) => Music.fromJson(json)).toList();
      } else {
        print('서버 응답 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }

    return _allMusicList;
  }

  // 나의 음악 리스트 가져오는 함수
  Future<List> fetchMymusicList(User user) async {
    print('나의음악 패치 실행');
    final String _myMusicListApi = 'http://${_localhost}:8080/favorite-music';

    Uri uri = Uri.parse(_myMusicListApi);

    uri = uri.replace(queryParameters: {'email': user.email});
    //실제 통신
    try {
      final response = await http.get(uri);
      print(response.body);
      if (response.statusCode == 200) {
        //final List<dynamic> data = json.decode(response.body);
        final List<dynamic> outerList = json.decode(response.body);
        final List<dynamic> innerList =
            outerList.expand((element) => element).toList();
        _myMusicList = innerList.map((json) => Music.fromJson(json)).toList();
        //_myMusicList = data.map((json) => Music.fromJson(json)).toList();
      } else {
        print('서버 응답 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }

    //all뮤직리스트에서 나의 뮤직리스트의 뮤직들을 좋아요 표시하기 위한 로직
    for (Music myMusic in _myMusicList) {
      myMusic.isLiked = true; // 나의 뮤직리스트는 디폴트로 좋아요
      for (Music allMusic in _allMusicList) {
        if (myMusic.title == allMusic.title) {
          allMusic.isLiked = true;
          break;
        }
      }
    }

    return _myMusicList;
  }

// 추천음악리스트 가져오는 함수
  Future<List> fetchRecommendMusicList(User user) async {
    print('추천음악 패치 실행');
    print(user.email);
    final String _recommendMusicListApi =
        'http://${_localhost}:8080/recommend-music';

    Uri uri = Uri.parse(_recommendMusicListApi);

    uri = uri.replace(queryParameters: {'email': user.email});
    //실제 통신
    try {
      final response = await http.get(uri);
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> nestedList = json.decode(response.body);

        for (List<dynamic> innerList in nestedList) {
          for (dynamic json in innerList) {
            _recommendMusicList.add(Music.fromJson(json));
          }
        }
      } else {
        print('서버 응답 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }

    return _recommendMusicList;
  }

  //음악 좋아요추가
  Future<void> updateMyMusic(Music music, User user) async {
    final String _updateMymusicApi = 'http://${_localhost}:8080/favorite-music';
    // 서버에 보낼 데이터를 Map 형태로 구성
    final Map<String, dynamic> requestData = {
      'email': user.email, // 사용자 이름
      'music_id': music.id, // 음악 제목
      'Rating': music.rating,
    };

    try {
      final response = await http.post(
        Uri.parse(_updateMymusicApi),
        body: json.encode(requestData),
        headers: {'Content-type': 'application/json'},
      );

      if (response.statusCode != 200) {
        print('서버 응답 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  //mymusic에서 제거
  Future<void> deleteMymusic(Music music, User user) async {
    final String _deleteMymusicApi =
        'http://${_localhost}:8080/favorite-music/${user.email}/${music.id}';
    // // 서버에 보낼 데이터를 Map 형태로 구성
    // final Map<String, dynamic> requestData = {
    //   'userName': user.email, // 사용자 이름
    //   'musicTitle': music.title, // 음악 제목
    // };

    try {
      final response = await http.delete(
        Uri.parse(_deleteMymusicApi),
        headers: {'Content-type': 'application/json'},
      );

      if (response.statusCode != 200) {
        print('서버 응답 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  Future<void> fetchMusicInfo(Music music) async {
    final String _musicInfoApi = 'http://${_localhost}:8080/music-information';
    Uri uri = Uri.parse(_musicInfoApi);

    uri = uri.replace(queryParameters: {'music_id': music.id.toString()});
    //실제 통신
    try {
      final response = await http.get(uri);

      Map<String, dynamic> data = json.decode(response.body);
      music.videoLink = data['v'];
      music.lyrics = data['lyrics_Text'];
      if (response.statusCode == 200) {
        print(response.body);
      } else {
        print('서버 응답 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }
}
