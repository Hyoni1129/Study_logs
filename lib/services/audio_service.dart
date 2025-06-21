import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  Future<void> playFocusCompleteSound() async {
    if (!_soundEnabled) return;
    
    try {
      // Play system sound for focus completion
      await SystemSound.play(SystemSoundType.click);
      
      // You can also play custom sounds from assets
      // await _audioPlayer.play(AssetSource('sounds/focus_complete.mp3'));
    } catch (e) {
      debugPrint('Error playing focus complete sound: $e');
    }
  }

  Future<void> playBreakCompleteSound() async {
    if (!_soundEnabled) return;
    
    try {
      // Play system sound for break completion
      await SystemSound.play(SystemSoundType.click);
      
      // You can also play custom sounds from assets
      // await _audioPlayer.play(AssetSource('sounds/break_complete.mp3'));
    } catch (e) {
      debugPrint('Error playing break complete sound: $e');
    }
  }

  Future<void> playTickSound() async {
    if (!_soundEnabled) return;
    
    try {
      // Play subtle tick sound
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Error playing tick sound: $e');
    }
  }

  Future<void> playStartSound() async {
    if (!_soundEnabled) return;
    
    try {
      // Play timer start sound
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Error playing start sound: $e');
    }
  }

  Future<void> playStopSound() async {
    if (!_soundEnabled) return;
    
    try {
      // Play timer stop sound
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('Error playing stop sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
