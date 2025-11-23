import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:fl_astro_circle/services/white_noise_generator.dart';

class CosmicAudioGenerator {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final WhiteNoiseGenerator _noiseGenerator = WhiteNoiseGenerator();

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  
  Function? _onStateChanged;

  CosmicAudioGenerator() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (_onStateChanged != null) {
        _onStateChanged!();
      }
    });
  }

  void setOnStateChanged(Function callback) {
    _onStateChanged = callback;
  }

  Future<String?> playCosmicMessage({
    required String messageId,
    required int durationSeconds,
    required String? audioFilePath,
    Function? onComplete,
  }) async {
    if (_isPlaying) {
      await stop();
    }

    try {
      String filePath;
      bool isNewFile = false;
      
      if (audioFilePath != null && await File(audioFilePath).exists()) {
        filePath = audioFilePath;
      } else {
        filePath = await _noiseGenerator.generateWhiteNoiseFile(durationSeconds, messageId);
        isNewFile = true;
      }
      
      await _audioPlayer.setAudioSource(AudioSource.file(filePath));

      _audioPlayer.play();

      Future.delayed(Duration(seconds: durationSeconds), () async {
        await stop();
        if (onComplete != null) {
          onComplete();
        }
      });
      
      return isNewFile ? filePath : null;
    } catch (e) {
      print('Error playing cosmic audio: $e');
      return null;
    }
  }

  Future<void> stop() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
    }
  }

  Future<void> pause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    }
  }

  Future<void> resume() async {
    if (!_isPlaying) {
      await _audioPlayer.play();
    }
  }

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Duration? get duration => _audioPlayer.duration;
  
  Duration get position => _audioPlayer.position;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

