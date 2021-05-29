import 'package:audioplayers/audioplayers.dart';

class Audio {
  static void playAudioFromLocalStorage(
      AudioPlayer audioPlayer, String path) async {
    await audioPlayer.play(path, isLocal: true);
  }

  static pauseAudio(AudioPlayer audioPlayer) async {
    int response = await audioPlayer.pause();
    if (response == 1) {
      // success
    } else {
      print('Some error occured in pausing');
    }
  }

  static resumeAudio(AudioPlayer audioPlayer) async {
    int response = await audioPlayer.resume();
    if (response == 1) {
      // success
    } else {
      print('Some error occured in resuming');
    }
  }

  static void stopAudio(AudioPlayer audioPlayer) async {
    await audioPlayer.stop();
  }
}
