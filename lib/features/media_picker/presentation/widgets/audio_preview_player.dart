import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/media_validators.dart';

class AudioPreviewPlayer extends StatefulWidget {
  final File file;

  const AudioPreviewPlayer({super.key, required this.file});

  @override
  State<AudioPreviewPlayer> createState() => _AudioPreviewPlayerState();
}

class _AudioPreviewPlayerState extends State<AudioPreviewPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.file.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.file.path.split(Platform.pathSeparator).last;
    final fileSize = widget.file.existsSync() ? widget.file.lengthSync() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderOverlay),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.cyanAccent.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppTheme.cyanAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AUDIO CLIP • ${MediaValidators.formatBytes(fileSize)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Audio Spectrum Waveform Visualizer simulation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(24, (index) {
              final heights = [12.0, 24.0, 36.0, 18.0, 42.0, 28.0, 14.0, 32.0, 46.0, 20.0, 38.0, 26.0];
              final height = heights[index % heights.length];
              final active = _isPlaying && (index / 24) <= (_position.inSeconds / (_duration.inSeconds > 0 ? _duration.inSeconds : 1));

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 4,
                height: _isPlaying ? height : (height * 0.4).clamp(6.0, 50.0),
                decoration: BoxDecoration(
                  color: active ? AppTheme.cyanAccent : AppTheme.borderOverlay,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Playback progress slider & duration text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                MediaValidators.formatDuration(_position),
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textMuted),
              ),
              IconButton(
                iconSize: 42,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  color: AppTheme.cyanAccent,
                ),
                onPressed: _togglePlay,
              ),
              Text(
                MediaValidators.formatDuration(_duration),
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
