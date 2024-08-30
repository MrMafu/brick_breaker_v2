import 'dart:async';
import 'dart:ui';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

//Deklarasi Class: Berisikan logging untuk rekam error, soloud, dan handle untuk soloud
class AudioController {
  static final Logger _log = Logger('AudioController');

  SoLoud? _soloud;
  SoundHandle? _musicHandle;

  //Inisialisasi soloud
  Future<void> initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
  }

  //Deinisialisasi soloud
  void dispose() {
    _soloud?.deinit();
  }

  //Putar sound
  Future<void> playSound(String assetKey) async {
    try {
      final source = await _soloud!.loadAsset(assetKey);
      await _soloud!.play(source);
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound '$assetKey'. Ignoring.", e);
    }
  }

  //Playback musik
  Future<void> startMusic() async {
    if (_musicHandle != null) {
      if (_soloud!.getIsValidVoiceHandle(_musicHandle!)) {
        _log.info('Music is already playing. Stopping first.');
        await _soloud!.stop(_musicHandle!);
      }
    }
    _log.info('Loading music');
    final musicSource = await _soloud!
        .loadAsset('assets/music/backsound.ogg', mode: LoadMode.disk);
    musicSource.allInstancesFinished.first.then((_) {
      _soloud!.disposeSource(musicSource);
      _log.info('Music source disposed');
      _musicHandle = null;
    });

    _log.info('Playing music');
    _musicHandle = await _soloud!.play(
      musicSource,
      volume: 0.6,
      looping: true,
      loopingStartAt: const Duration(seconds: 25, milliseconds: 43),
    );
  }

  void fadeOutMusic() {
    if (_musicHandle == null) {
      _log.info('Nothing to fade out');
      return;
    }
    const length = Duration(seconds: 5);
    _soloud!.fadeVolume(_musicHandle!, 0, length);
    _soloud!.scheduleStop(_musicHandle!, length);
  }

  void applyFilter() {
    _soloud!.addGlobalFilter(FilterType.freeverbFilter);
    _soloud!.setFilterParameter(FilterType.freeverbFilter, 0, 0.2);
    _soloud!.setFilterParameter(FilterType.freeverbFilter, 2, 0.9);
  }

  void removeFilter() {
    _soloud!.removeGlobalFilter(FilterType.freeverbFilter);
  }
}
