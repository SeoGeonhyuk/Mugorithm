const express = require('express');
const app = express();
const server = require("http").createServer(app);
const mysql = require('mysql');
const qs = require("node:querystring");
const path = require("path");
const util = require("util");
const fs = require("fs");
const csv = require("csv-parser");
const bodyParser = require("body-parser");
const pipeline = util.promisify(require('stream').pipeline);
//사전에 node.js를 설치할 것
//api 실행을 위해서는 해당 DB_api 폴더 내부에서
//sudo npm install(최초 한 번만 오류 생기면 다시) 진행 후
//sudo node index.js 실행
//그렇게 하면 서버가 실행되며 서버를 종료하고 싶을 경우에는 컨트롤+c
//테스트 툴은 포스트맨 추천
//db 사용전에 반드시 https://devpouch.tistory.com/114를 참고할 것
//db sql파일은 db폴더 내부에 존재
const db = {
    user : {
        host: 'localhost',
        //db 폴더에 있는 db를 활용하여 각자 db폴더를 업데이트 할 것
        //다른 사람들에게 db파일을 공유해주고 싶다면 mysqldump라는 유틸리티를 찾아볼 것
        //각자의 db user와 password입력
        user: 'root',
        password: '',
        database: 'user'
    },
    music : {
        host: 'localhost',
        //db 폴더에 있는 db를 활용하여 각자 db폴더를 업데이트 할 것
        //다른 사람들에게 db파일을 공유해주고 싶다면 mysqldump라는 유틸리티를 찾아볼 것
        //각자의 db user와 password입력
        user: 'root',
        password: '',
        database: 'music'
    }
}

const connection = mysql.createConnection(db.user);
connection.connect((err) => {
    if (err) {
      console.error('MySQL connection failed: ' + err.stack);
      return;
    }
    console.log('Connected to MySQL database');
  });
app.use(bodyParser.json());

app.get("/favorite-music", async (req, res) => {
  try{
    const email = req.query.email;
    const favorite_Query = `SELECT Music_ID_Liked FROM USER_FAVORITE WHERE Email = ${connection.escape(email)}`;
    await queryPromise(`USE ${db.user.database}`);
    const resulted = await queryPromise(favorite_Query);
    const results = resulted.map(row => row.Music_ID_Liked);
    console.log(results);
    await queryPromise(`USE ${db.music.database}`);              
    const MusicFull = [];
    for (element of results) {
      const k = await queryPromise(`SELECT * FROM MUSIC2 WHERE ID = ${element}`);
      MusicFull.push(k);
    }
    res.status(200).send(MusicFull);
  } catch (err) {
    console.error("ERROR : ", err);
    res.status(500).send("Internal Server Error!");
  }
});


const queryPromise = (sql, values) => {
    return new Promise((resolve, reject) => {
      connection.query(sql, values, (err, results) => {
        if (err) {
          reject(err);
        } else {
          resolve(results);
        }
      });
    });
  };

// 로그인 API
app.post("/login", async (req, res) => {
    console.log("login api 동작");
    const { email, password } = req.body;
    try {
      await queryPromise(`USE ${db.user.database}`);
      const results = await queryPromise(
        `SELECT * FROM USER WHERE Email = ? AND Password_hash = ?`,
        [email, password]
      );
      if (!results.length) {
        res.status(401).send("Login Failed!");
      } else {
        res.status(200).send("Login Success!");
      }
    } catch (err) {
      console.error("Error:", err);
      res.status(500).send("Internal Server Error!");
    }
  });
  
  // 회원 가입 API
  app.post("/register", async (req, res) => {
    const { email, password } = req.body;
    try {
      await queryPromise(`USE ${db.user.database}`);
      const user = await queryPromise(
        `SELECT * FROM USER WHERE Email = ?`,
        [email]
      );
      if (!user.length) {
        await queryPromise(
          `INSERT INTO USER (Email, Password_hash) VALUES (?, ?)`,
          [email, password]
        );
        res.status(200).send(`${email} 유저 회원 가입 완료`);
      } else {
        res.status(400).send(`${email} 중복된 유저 확인`);
      }
    } catch (err) {
      console.error("Error:", err);
      res.status(500).send("Internal Server Error!");
    }
  });
  
  // 모든 음악들을 가져오는 API
  app.get("/musics", async (req, res) => {
    try {
      await queryPromise(`USE ${db.music.database}`);
      const results = await queryPromise(`SELECT * FROM MUSIC2`);
      console.log("모든 음악 가져오기 완료!");
      res.status(200).send(results);
    } catch (err) {
      console.error("Error:", err);
      res.status(500).send("Internal Server Error!");
    }
  });
  
  // 각 유저의 좋아하는 음악들을 가져오는 API
  // app.get("/favorite-music", async (req, res) => {
  //   const { email } = req.query;
  //   const favorite_Query = `SELECT Music_ID_Liked FROM USER_FAVORITE WHERE Email = ?`;
  //   try {
  //     await queryPromise(`USE ${db.user.database}`);
  //     const results = await queryPromise(favorite_Query, [email]);
  
  //     // ... (이하 생략)
  //   } catch (err) {
  //     console.error("Error:", err);
  //     res.status(500).send("Internal Server Error!");
  //   }
  // });
  
  // 음악에 좋아요 버튼을 눌렀을 경우 해당 음악의 user favorite에 추가하는 API
  app.post("/favorite-music", async (req, res) => {
    const { email, music_id, Rating } = req.body;
    try {
      await queryPromise(`USE ${db.user.database}`);
      await queryPromise(
        `INSERT INTO USER_FAVORITE (Rating, Email, Music_ID_Liked) VALUES (?, ?, ?)`,
        [Rating ,email, music_id]
      );
      res
        .status(200)
        .send(`${email} 사용자, ${music_id}를 좋아하는 음악 리스트에 추가 완료`);
    } catch (err) {
      console.error("Error:", err);
      res.status(500).send("Internal Server Error!");
    }
  });
  
  // 좋아요 한 음악에 다시 좋아요를 눌렀을 경우 사용자의 좋아하는 음악 리스트에서 제거하는 API
  app.delete("/favorite-music/:email/:music_id", async (req, res) => {
    const email = req.params.email;
    const music_id = req.params.music_id;
    try {
      await queryPromise(`USE ${db.user.database}`);
      const result = await queryPromise(
        `SELECT * FROM USER_FAVORITE WHERE Email = ? AND Music_ID_Liked = ?`, [email, music_id]);
      if (result.length > 0) {
        await queryPromise(`DELETE FROM USER_FAVORITE WHERE Email = ? AND Music_ID_Liked = ?`, [email, music_id]);
        res.status(200).send("삭제 완료");
      }
      else{
      res.status(404).send("이미 삭제되었거나 찾을 수 없습니다.");
      }
    } catch (err) {
      console.error("Error:", err);
      res.status(500).send("Internal Server Error!");
    }
  });
  
//해당 음악을 터치했을 때 음악의 가사와 뮤직 비디오의 url을 가져오는 api
//query로 보내주어야 할 것 : (music_id)
app.get("/music-information", async (req, res) => {
    try {
      const music_id = req.query.music_id;
  
      await queryPromise(`USE ${db.music.database}`);
      
      const music_info = await queryPromise('SELECT * FROM MUSIC_INFO2 WHERE Music_Info_ID = ?', [music_id]);
  
      if (music_info.length === 0) {
        res.status(404).send("해당되는 데이터가 없습니다.");
        return;
      }
  
      const lyricsPath = `./db/Lyrics/${music_info[0].Lyrics_ID}/${music_info[0].Lyrics_ID}.txt`;
      const lyrics = await fs.promises.readFile(lyricsPath, 'utf8');
  
      const v = music_info[0].Music_Video;
      const lyrics_Text = lyrics;
      const obj = {
        v,
        lyrics_Text
      };
  
      res.status(200).json(obj);
    } catch (error) {
      console.error('Error:', error);
      res.status(500).send("Internal Server Error!");
    }
  });
  
  async function countOccurrences(arr, recommend_Number) {
    if (arr.length === 0) {
      // 배열이 비어있을 경우 빈 배열 반환
      return [];
    }
  
    const occurrences = {};
    const real_Occurrences = new Set();
  
    // 배열 내의 각 이메일 주소에 대해 반복
    arr.forEach(email => {
      // 현재 이메일 주소가 occurrences 객체에 이미 존재하는지 확인
      if (occurrences[email]) {
        // 존재한다면 등장 횟수 증가
        occurrences[email]++;
        if (occurrences[email] >= recommend_Number) {
          real_Occurrences.add(email);
        }
      } else {
        // 존재하지 않는다면 초기값 1로 설정
        occurrences[email] = 1;
      }
    });
    return real_Occurrences.size > 0 ? Array.from(real_Occurrences) : [];
  }
  
  async function arrayDifference(arr1, arr2) {
    return arr1.filter(item => !arr2.includes(item));
}
  

app.get("/recommend-music", async (req, res) => {
  try {
    const recommend_Number = 2;
    await queryPromise(`USE ${db.user.database}`);
    const email = req.query.email;
    const favorite_Musics = await queryPromise(`SELECT Music_ID_Liked FROM USER_FAVORITE WHERE Email = ?`, [email]);
    const favoriteMusicIDs = favorite_Musics.map(row => row.Music_ID_Liked);
    if (favoriteMusicIDs.length === 0) {
      res.status(404).send("아직 추천할 수 있는 곡이 없습니다.");
      return;
    }

    let recommend_User_Array = [];

    for (const liked_Id of favoriteMusicIDs) {
      const favorite_Users = await queryPromise(`SELECT Email FROM USER_FAVORITE WHERE Music_ID_Liked = ?`, [liked_Id]);
      recommend_User_Array = recommend_User_Array.concat(favorite_Users);
    }

    const non_UniqueEmails = recommend_User_Array.map(rowDataPacket => rowDataPacket.Email);
    const final_Recommend_User = await countOccurrences(non_UniqueEmails, recommend_Number);
    const recommend_Musics_Set = new Set();
    for (const email_r of final_Recommend_User) {
      const duplication_Existing_Musics = await queryPromise(`SELECT Music_ID_Liked FROM MaterializedTable2 WHERE Email = ? AND Rating >= 4`, [email_r]);
      const extractedMusicIDs = duplication_Existing_Musics.map(row => row.Music_ID_Liked);
      for (const dem of extractedMusicIDs) {
        recommend_Musics_Set.add(dem);
      }
    }
    

    const recommend_Musics_Array = Array.from(recommend_Musics_Set);
    const final = await arrayDifference(recommend_Musics_Array, favoriteMusicIDs);
    await queryPromise(`USE ${db.music.database}`);
    const random_Query = await queryPromise(`SELECT ID FROM Music2 ORDER BY RAND() LIMIT 1;`);
    const random_ele = random_Query.map(row => row.Music_ID);
    const random_Query2 = await queryPromise(`SELECT ID FROM Music2 ORDER BY RAND() LIMIT 1;`);
    const random_ele2 = random_Query2.map(row => row.Music_ID);
    final.push(random_ele[0]);
    final.push(random_ele2[0]);
    const final_set = new Set(final);
    const final2 = Array.from(final_set);
    await queryPromise(`USE ${db.user.database}`);

    const my_favorites = await queryPromise(`SELECT Music_ID_Liked FROM USER_FAVORITE WHERE Email = ?`, [email]);
    const my_favorites2 = my_favorites.map(row => row.Music_ID_Liked);
    let difference = final2.filter(element => !my_favorites2.includes(element));

    console.log(difference);
    if (final.length === 0) {
      res.status(404).send("아직 추천할 수 있는 곡이 없습니다");
    } else {
      await queryPromise(`USE ${db.music.database}`);
      const final_Info = []
      for (const ele of difference) {
        const resource = await queryPromise(`SELECT * FROM MUSIC2 WHERE ID = ?`, [ele]);
        final_Info.push(resource);
      }
      res.status(200).send(final_Info);
    }
  } catch (error) {
    console.error('Error:', error);
    res.status(500).send("Internal Server Error!");
  }
});

const PORT = 8080;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });