import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  final AudioPlayer _player = AudioPlayer();

  AudioManager._internal();

  Future<void> _playSound(String fileName) async {
    try {
      // Dosya var mı yok mu kontrolü zor olduğu için try-catch ile sarmalıyoruz.
      // Eğer assets/audio/ altında dosya yoksa sessizce hatayı yutar.
      await _player.stop(); // Önceki sesi durdur (Overlap olmasın)
      await _player.play(AssetSource('audio/$fileName'));
    } catch (e) {
      // Ses dosyası yoksa veya hata olursa sessiz kal
      // print("Audio Error (Safe to ignore): $e");
    }
  }

  void playDiceRoll() => _playSound('dice_roll.mp3');
  void playSuccess() => _playSound('success.mp3');
  void playError() => _playSound('error.mp3');
  void playPurchase() => _playSound('cash.mp3');
  void playGameOver() => _playSound('fanfare.mp3');
  void playTurnChange() => _playSound('whoosh.mp3');
}
