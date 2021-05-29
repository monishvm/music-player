import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/audio.dart';
import 'package:music_player/screens/song_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:async/async.dart';

enum AfterSong {
  loop,
  next,
  stop,
}

class AllSongs extends StatefulWidget {
  @override
  _AllSongsState createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  MetadataRetriever retriever = MetadataRetriever();
  AudioPlayer audioPlayer;
  SongInfo selectedSong;
  List<SongInfo> songs = [];
  AfterSong afterSong = AfterSong.stop;

  @override
  void initState() {
    super.initState();

    //Audio Player
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerStateChanged.listen((event) {
      // after Song complete
      if (event == PlayerState.COMPLETED) {
        setState(() {
          SongInfo nextSong = songs[songs.indexOf(selectedSong) + 1];
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

  // To get song only if any changes
  _getAllSongs() {
    return this._memoizer.runOnce(() async {
      await Future.delayed(Duration(seconds: 2));
      return songsPath();
    });
  }

  Future<List<SongInfo>> songsPath() async {
    List<FileSystemEntity> _files;
    SongInfo songInfo;
    Metadata metadata;

    if (await Permission.storage.request().isGranted) {
      Directory dir = Directory('/storage/emulated/0/');
      _files = dir.listSync(recursive: true, followLinks: false);
      for (FileSystemEntity entity in _files) {
        Uint8List image;
        String path = entity.path;
        if (path.endsWith('.mp3')) {
          try {
            await retriever.setFile(File(path));
            image = retriever.albumArt;
          } catch (e) {
            image = null;
          }
          metadata = await retriever.metadata;
          songInfo = SongInfo.setData(metadata, image, path);
          songs.add(songInfo);
        }
      }
      return songs;
    } else {
      return null;
    }
  }

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
        child: FutureBuilder(
          future: _getAllSongs(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return _buildListTile(snapshot.data[index]);
                  },
                );
              } else {
                return Center(child: Text('Storage Permission Not Given'));
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  ListTile _buildListTile(SongInfo currentSong) {
    var defaultImage = Image.asset(
      'assets/default_music_image.jpg',
      height: 50,
      width: 100,
      fit: BoxFit.cover,
    );
    return ListTile(
      leading: currentSong.albumArt != null
          ? Image.memory(
              currentSong.albumArt,
              height: 50,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return defaultImage;
              },
            )
          : defaultImage,
      tileColor:
          selectedSong != null && selectedSong.filePath == currentSong.filePath
              ? Colors.grey.shade300
              : Colors.white,
      trailing:
          selectedSong != null && selectedSong.filePath == currentSong.filePath
              ? _pauseStopButton()
              : _playButton(currentSong),
      title: Text(currentSong.filePath.split('/').last.split('(')[0] ??
          currentSong.filePath.split('/').last),
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
            },
          ),
          IconButton(
            icon: Icon(
              audioPlayer.state == PlayerState.PAUSED
                  ? Icons.play_arrow
                  : Icons.pause,
              size: 40,
            ),
            onPressed: () {
              setState(() {
                audioPlayer.state == PlayerState.PAUSED
                    ? Audio.resumeAudio(audioPlayer)
                    : Audio.pauseAudio(audioPlayer);
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
        Audio.playAudioFromLocalStorage(audioPlayer, currenttSong.filePath);
        setState(() {
          selectedSong = currenttSong;
        });
      },
    );
  }
}
