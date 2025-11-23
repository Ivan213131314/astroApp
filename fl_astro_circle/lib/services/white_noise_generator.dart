import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

enum NoiseType {
  white,
  pink,
  brown,
  crackle,
  modulated,
  beep,
}

class WhiteNoiseGenerator {
  static const int sampleRate = 44100;
  static const int bitsPerSample = 16;
  static const int numChannels = 1;

  Future<String> generateWhiteNoiseFile(int durationSeconds, String messageId) async {
    final numSamples = sampleRate * durationSeconds;
    final pcmData = _generateVariedNoiseSamples(numSamples);
    
    final wavData = _createWavFile(pcmData);
    
    final appDir = await getApplicationDocumentsDirectory();
    final cosmicDir = Directory('${appDir.path}/cosmic_messages');
    if (!await cosmicDir.exists()) {
      await cosmicDir.create(recursive: true);
    }
    
    final filePath = '${cosmicDir.path}/cosmic_$messageId.wav';
    
    final file = File(filePath);
    await file.writeAsBytes(wavData);
    
    return filePath;
  }

  List<int> _generateVariedNoiseSamples(int numSamples) {
    final random = Random();
    final samples = <int>[];
    
    final segmentLength = sampleRate ~/ 2;
    int currentSample = 0;
    
    double pinkB0 = 0.0;
    double pinkB1 = 0.0;
    double pinkB2 = 0.0;
    double pinkB3 = 0.0;
    double pinkB4 = 0.0;
    double pinkB5 = 0.0;
    double pinkB6 = 0.0;
    
    double brownValue = 0.0;
    int beepCounter = 0;
    double beepFrequency = 0.0;
    int beepDuration = 0;
    
    while (currentSample < numSamples) {
      final noiseType = NoiseType.values[random.nextInt(NoiseType.values.length)];
      final segmentSize = min(segmentLength, numSamples - currentSample);
      
      for (int i = 0; i < segmentSize; i++) {
        double sample = 0.0;
        
        switch (noiseType) {
          case NoiseType.white:
            sample = _generateWhiteNoise(random);
            break;
          
          case NoiseType.pink:
            final whiteNoise = _generateWhiteNoise(random);
            pinkB0 = 0.99886 * pinkB0 + whiteNoise * 0.0555179;
            pinkB1 = 0.99332 * pinkB1 + whiteNoise * 0.0750759;
            pinkB2 = 0.96900 * pinkB2 + whiteNoise * 0.1538520;
            pinkB3 = 0.86650 * pinkB3 + whiteNoise * 0.3104856;
            pinkB4 = 0.55000 * pinkB4 + whiteNoise * 0.5329522;
            pinkB5 = -0.7616 * pinkB5 - whiteNoise * 0.0168980;
            sample = pinkB0 + pinkB1 + pinkB2 + pinkB3 + pinkB4 + pinkB5 + pinkB6 + whiteNoise * 0.5362;
            sample *= 0.11;
            pinkB6 = whiteNoise * 0.115926;
            break;
          
          case NoiseType.brown:
            final whiteNoise = _generateWhiteNoise(random);
            brownValue = (brownValue + (0.02 * whiteNoise)) / 1.02;
            sample = brownValue * 3.5;
            break;
          
          case NoiseType.crackle:
            if (random.nextDouble() < 0.05) {
              sample = (random.nextDouble() * 2 - 1) * 1.5;
            } else {
              sample = _generateWhiteNoise(random) * 0.3;
            }
            break;
          
          case NoiseType.modulated:
            final frequency = 0.5 + random.nextDouble() * 2;
            final phase = (currentSample + i) / sampleRate * frequency * 2 * pi;
            final modulation = 0.3 + 0.7 * sin(phase).abs();
            sample = _generateWhiteNoise(random) * modulation;
            break;
          
          case NoiseType.beep:
            if (beepCounter == 0) {
              beepFrequency = 200 + random.nextDouble() * 2000;
              beepDuration = (sampleRate * (0.05 + random.nextDouble() * 0.2)).toInt();
              beepCounter = beepDuration;
            }
            
            final phase = (beepDuration - beepCounter) / sampleRate * beepFrequency * 2 * pi;
            final envelope = sin((beepDuration - beepCounter) / beepDuration * pi);
            sample = sin(phase) * envelope * 0.6;
            beepCounter--;
            
            if (random.nextDouble() < 0.3) {
              sample += _generateWhiteNoise(random) * 0.1;
            }
            break;
        }
        
        if (random.nextDouble() < 0.08 && noiseType != NoiseType.beep) {
          final beepFreq = 400 + random.nextDouble() * 1500;
          final beepPhase = i / sampleRate * beepFreq * 2 * pi;
          sample += sin(beepPhase) * 0.4;
        }
        
        final amplitude = 32767 * 0.8;
        final intSample = (sample * amplitude).clamp(-32768, 32767).toInt();
        samples.add(intSample);
      }
      
      currentSample += segmentSize;
    }
    
    return samples;
  }

  double _generateWhiteNoise(Random random) {
    return random.nextDouble() * 2 - 1;
  }

  Uint8List _createWavFile(List<int> samples) {
    final dataSize = samples.length * 2;
    final fileSize = dataSize + 36;
    
    final byteData = ByteData(fileSize + 8);
    
    int offset = 0;
    
    byteData.setUint8(offset++, 0x52);
    byteData.setUint8(offset++, 0x49);
    byteData.setUint8(offset++, 0x46);
    byteData.setUint8(offset++, 0x46);
    
    byteData.setUint32(offset, fileSize, Endian.little);
    offset += 4;
    
    byteData.setUint8(offset++, 0x57);
    byteData.setUint8(offset++, 0x41);
    byteData.setUint8(offset++, 0x56);
    byteData.setUint8(offset++, 0x45);
    
    byteData.setUint8(offset++, 0x66);
    byteData.setUint8(offset++, 0x6D);
    byteData.setUint8(offset++, 0x74);
    byteData.setUint8(offset++, 0x20);
    
    byteData.setUint32(offset, 16, Endian.little);
    offset += 4;
    
    byteData.setUint16(offset, 1, Endian.little);
    offset += 2;
    
    byteData.setUint16(offset, numChannels, Endian.little);
    offset += 2;
    
    byteData.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    byteData.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    byteData.setUint16(offset, blockAlign, Endian.little);
    offset += 2;
    
    byteData.setUint16(offset, bitsPerSample, Endian.little);
    offset += 2;
    
    byteData.setUint8(offset++, 0x64);
    byteData.setUint8(offset++, 0x61);
    byteData.setUint8(offset++, 0x74);
    byteData.setUint8(offset++, 0x61);
    
    byteData.setUint32(offset, dataSize, Endian.little);
    offset += 4;
    
    for (int i = 0; i < samples.length; i++) {
      byteData.setInt16(offset, samples[i], Endian.little);
      offset += 2;
    }
    
    return byteData.buffer.asUint8List();
  }

}

