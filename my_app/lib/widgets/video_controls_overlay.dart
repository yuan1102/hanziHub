import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

/// 视频播放控件 overlay
/// 包含：播放/暂停按钮、进度条(Slider)、时间显示、重新播放按钮、全屏切换
class VideoControlsOverlay extends StatelessWidget {
  final Player player;
  final bool showControls;
  final bool isCompleted;
  final bool isFullscreen;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onReplay;
  final VoidCallback onSliderDragStart;
  final VoidCallback onSliderDragEnd;
  final VoidCallback onToggleFullscreen;

  const VideoControlsOverlay({
    super.key,
    required this.player,
    required this.showControls,
    required this.isCompleted,
    this.isFullscreen = false,
    required this.onPlayPause,
    required this.onSeek,
    required this.onReplay,
    required this.onSliderDragStart,
    required this.onSliderDragEnd,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _buildReplayOverlay();
    }

    return AnimatedOpacity(
      opacity: showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !showControls,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      initialData: player.state.position,
      builder: (context, positionSnap) {
        return StreamBuilder<Duration>(
          stream: player.stream.duration,
          initialData: player.state.duration,
          builder: (context, durationSnap) {
            final position = positionSnap.data ?? Duration.zero;
            final duration = durationSnap.data ?? Duration.zero;
            final maxMs = duration.inMilliseconds.toDouble();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: player.stream.playing,
                    initialData: player.state.playing,
                    builder: (context, playingSnap) {
                      final isPlaying = playingSnap.data ?? false;
                      return GestureDetector(
                        onTap: onPlayPause,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                        activeTrackColor: Colors.orange,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Colors.orange,
                        overlayColor: Colors.orange.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: maxMs > 0
                            ? position.inMilliseconds
                                .toDouble()
                                .clamp(0, maxMs)
                            : 0,
                        max: maxMs > 0 ? maxMs : 1,
                        onChangeStart: (_) => onSliderDragStart(),
                        onChanged: (v) {
                          onSeek(Duration(milliseconds: v.toInt()));
                        },
                        onChangeEnd: (_) => onSliderDragEnd(),
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onToggleFullscreen,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isFullscreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReplayOverlay() {
    return Container(
      color: Colors.black45,
      child: Center(
        child: GestureDetector(
          onTap: onReplay,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.replay_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '再看一遍',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
