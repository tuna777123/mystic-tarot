import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MysticSoundscape {
  MysticSoundscape._();

  static final MysticSoundscape instance = MysticSoundscape._();

  final AudioPlayer _player = AudioPlayer(playerId: 'mystic-effects');
  bool _enabled = true;
  bool _loaded = false;

  bool get enabled => _enabled;

  Future<void> load() async {
    if (_loaded) return;
    final preferences = await SharedPreferences.getInstance();
    _enabled = preferences.getBool('sound_effects') ?? true;
    _loaded = true;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    _loaded = true;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('sound_effects', value);
    if (!value) await _player.stop();
  }

  Future<void> selectCard() => _play('audio/card-select.mp3', volume: .6);

  Future<void> sealSelection() => _play('audio/seal.mp3', volume: .75);

  Future<void> revealCards() => _play('audio/reveal.mp3', volume: .85);

  Future<void> _play(String asset, {required double volume}) async {
    await load();
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(asset), volume: volume);
    } catch (_) {
      // Sound is enhancement-only; a reading must never fail with audio.
    }
  }
}
