import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quiver/iterables.dart';

enum AfterSong {
  loop,
  next,
  stop,
}

enum Songs {
  hasInfo,
  path,
  info,
}

class AllSongs extends StatefulWidget {
  @override
  _AllSongsState createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  AudioPlayer audioPlayer;
  SongInfo selectedSong;
  List<SongInfo> songs = [];
  // Map<Songs, dynamic> songs;
  AfterSong afterSong = AfterSong.stop;
  FlutterAudioQuery audioQuery;

  @override
  void initState() {
    super.initState();

    //Audio Query
    audioQuery = FlutterAudioQuery();

    //Audio Player
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.COMPLETED) {
        setState(() {
          SongInfo nextSong;
          songs.forEach((element) {
            if (selectedSong.id == element.id) {
              nextSong = songs[songs.indexOf(element) + 1];
            }
          });
          SongInfo sameSong = selectedSong;
          if (afterSong == AfterSong.next) {
            Audio.playAudioFromLocalStorage(audioPlayer, nextSong.filePath);
            selectedSong = nextSong;
          } else if (afterSong == AfterSong.loop) {
            Audio.playAudioFromLocalStorage(audioPlayer, sameSong.filePath);
          } else if (afterSong == AfterSong.stop) {
            Audio.stopAudio(audioPlayer);
          }
        });
      } else if (event == PlayerState.STOPPED) {
        setState(() {
          selectedSong = null;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  // Stream<List<String>> songsPath() async* {
  //   List<FileSystemEntity> _files;

  //   if (await Permission.storage.request().isGranted) {
  //     Directory dir = Directory('/storage/emulated/0/');
  //     _files = dir.listSync(recursive: true, followLinks: false);
  //     for (FileSystemEntity entity in _files) {
  //       String path = entity.path.toString();
  //       if (path.endsWith('.mp3')) {
  //         songs.add(path);
  //       }
  //     }
  //     yield songs;
  //   }
  // }

  Stream<List<SongInfo>> songInfoo() async* {
    Map<Songs, dynamic> song = {
      Songs.hasInfo: '',
      Songs.info: '',
      Songs.path: '',
    };

    if (await Permission.storage.request().isGranted) {
      songs = await audioQuery.getSongs();
      yield songs;
    }
  }

  // Stream<List<SongInfo>> songInfoo() async* {
  //   Map<Songs, dynamic> song;

  //   List<String> manualList;

  //   Directory dir = Directory('/storage/emulated/0/');
  //   List<FileSystemEntity> _files =
  //       dir.listSync(recursive: true, followLinks: false);
  //   for (FileSystemEntity entity in _files) {
  //     String path = entity.path.toString();
  //     if (path.endsWith('.mp3')) {
  //       manualList.add(path);
  //     }
  //   }

  //   if (await Permission.storage.request().isGranted) {
  //     for (var info in zip([await audioQuery.getSongs(), manualList])) {
  //       SongInfo func = info[0];
  //       String man = info[1];
  //       String n = man.split('mp3')[0].toString().split('/').last.split('(')[0];
  //       if (func.title == n) {
  //         song = {
  //           Songs.hasInfo: true,
  //           Songs.info: func,
  //           Songs.path: '',
  //         };
  //       } else {
  //         song = {
  //           Songs.hasInfo: false,
  //           Songs.info: '',
  //           Songs.path: man,
  //         };
  //       }
  //       // songs.add(song);
  //     }
  //     yield songs;
  //   }
  // }

  String printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              afterSong == AfterSong.next
                  ? Icons.next_plan
                  : afterSong == AfterSong.loop
                      ? Icons.loop
                      : Icons.stop,
            ),
            onPressed: () {
              setState(() {
                if (afterSong == AfterSong.next) {
                  afterSong = AfterSong.loop;
                } else if (afterSong == AfterSong.loop) {
                  afterSong = AfterSong.stop;
                } else if (afterSong == AfterSong.stop) {
                  afterSong = AfterSong.next;
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: songInfoo(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return _buildListTile(snapshot.data[index]);
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  ListTile _buildListTile(SongInfo currentSong) {
    return ListTile(
      tileColor: selectedSong != null && selectedSong.id == currentSong.id
          ? Colors.grey.shade300
          : Colors.white,
      trailing: selectedSong != null && selectedSong.id == currentSong.id
          ? _pauseStopButton()
          : _playButton(currentSong),
      title: Text(
        // currentSong
        //     .toString()
        //     .split('mp3')[0]
        //     .toString()
        //     .split('/')
        //     .last
        //     .split('(')[0],
        currentSong.title,
      ),
    );
  }

  Container _pauseStopButton() {
    return Container(
      width: 100,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.stop,
              size: 40,
            ),
            onPressed: () {
              Audio.stopAudio(audioPlayer);
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(
              audioPlayer.state == PlayerState.PLAYING
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 40,
            ),
            onPressed: () {
              setState(() {
                audioPlayer.state == PlayerState.PLAYING
                    ? Audio.pauseAudio(audioPlayer)
                    : Audio.resumeAudio(audioPlayer);
              });
            },
          ),
        ],
      ),
    );
  }

  IconButton _playButton(SongInfo currenttSong) {
    return IconButton(
      icon: Icon(
        Icons.play_arrow,
        size: 40,
      ),
      onPressed: () {
        setState(() {
          selectedSong = currenttSong;
        });
        Audio.playAudioFromLocalStorage(audioPlayer, currenttSong.filePath);
      },
    );
  }
}
