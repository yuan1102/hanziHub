import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';

import '../models/character_entry.dart';
import '../services/video_cache_manager.dart';
import '../widgets/video_controls_overlay.dart';

/// 视频播放页
/// 需求：3.2、3.3、4.1、4.2、4.3、4.4
class VideoPlayerPage extends StatefulWidget {
  final CharacterEntry entry;

  const VideoPlayerPage({super.key, required this.entry});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final Player _player;
  late final VideoController _videoController;
  bool _hasError = false;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isCompleted = false;
  Timer? _hideControlsTimer;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<String>? _errorSub;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _completedSub = _player.stream.completed.listen((completed) {
      if (completed && mounted) {
        setState(() {
          _isCompleted = true;
        });
      }
    });

    _errorSub = _player.stream.error.listen((error) {
      debugPrint('视频播放错误: $error');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });

    try {
      Media media;
      switch (widget.entry.videoSource) {
        case VideoSource.builtIn:
          media = Media('asset:///${widget.entry.videoPath}');
          break;
        case VideoSource.userUploaded:
          final docDir = await getApplicationDocumentsDirectory();
          media = Media('${docDir.path}/${widget.entry.videoPath}');
          break;
        case VideoSource.remote:
          // 远程视频：智能播放策略
          // 1. 首次：直接播放在线地址（即时播放）
          // 2. 静默后台下载并缓存
          // 3. 后续：使用缓存（无需下载）
          final videoUrl = widget.entry.videoUrl ?? '';
          final cachedPath = await VideoCacheManager.getCachePath(videoUrl);
          final videoFile = File(cachedPath);

          // 检查是否已有缓存
          if (await videoFile.exists()) {
            // 缓存存在：使用缓存播放
            debugPrint('使用缓存视频: $cachedPath');
            media = Media(cachedPath);
          } else {
            // 缓存不存在：直接播放在线地址（即时响应）
            debugPrint('直接播放在线视频: $videoUrl');
            media = Media(videoUrl);

            // 同时后台静默下载缓存（不阻塞 UI）
            _silentDownloadVideo(videoUrl);
          }
          break;
      }

      await _player.open(media);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startHideControlsTimer();
      }
    } catch (e) {
      debugPrint('视频初始化失败: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _completedSub?.cancel();
    _errorSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (!_isInitialized) return;

    if (_isCompleted) {
      await _player.seek(Duration.zero);
      setState(() {
        _isCompleted = false;
      });
      await _player.play();
    } else if (_player.state.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }

    _resetHideControlsTimer();
    if (mounted) setState(() {});
  }

  Future<void> _onSeek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> _onReplay() async {
    await _player.seek(Duration.zero);
    setState(() {
      _isCompleted = false;
    });
    await _player.play();
    _resetHideControlsTimer();
  }

  void _onTapVideo() {
    if (_isCompleted) return;

    if (_showControls) {
      _hideControlsTimer?.cancel();
      setState(() {
        _showControls = false;
      });
    } else {
      _resetHideControlsTimer();
    }
  }

  Future<void> _enterFullscreen() async {
    _hideControlsTimer?.cancel();

    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _FullscreenVideoPage(
          player: _player,
          videoController: _videoController,
          isCompleted: _isCompleted,
          onPlayPause: _togglePlayPause,
          onSeek: _onSeek,
          onReplay: _onReplay,
          onCompletedChanged: (completed) {
            if (mounted) {
              setState(() {
                _isCompleted = completed;
              });
            }
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );

    // 从全屏返回后同步状态
    if (mounted) {
      setState(() {
        _showControls = true;
      });
      if (_player.state.playing) {
        _startHideControlsTimer();
      }
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _player.state.playing) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _resetHideControlsTimer() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  /// 静默后台下载视频（不显示加载界面）
  Future<void> _silentDownloadVideo(String videoUrl) async {
    try {
      debugPrint('后台静默下载视频: $videoUrl');
      final cachedPath = await VideoCacheManager.getOrDownloadVideo(videoUrl);

      if (cachedPath != null) {
        debugPrint('视频已缓存: $cachedPath');
      }
    } catch (e) {
      debugPrint('后台下载失败（忽略）: $e');
      // 静默失败，不显示任何错误信息，用户已在线播放了
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('该视频暂不可用', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              '视频初始化中...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Video(
              controller: _videoController,
              controls: NoVideoControls,
            ),

            // 缓冲指示器
            StreamBuilder<bool>(
              stream: _player.stream.buffering,
              initialData: _player.state.buffering,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // 播放控件 overlay
            GestureDetector(
              onTap: _onTapVideo,
              behavior: HitTestBehavior.opaque,
              child: VideoControlsOverlay(
                player: _player,
                showControls: _showControls,
                isCompleted: _isCompleted,
                onPlayPause: _togglePlayPause,
                onSeek: _onSeek,
                onReplay: _onReplay,
                onSliderDragStart: () => _hideControlsTimer?.cancel(),
                onSliderDragEnd: () => _startHideControlsTimer(),
                onToggleFullscreen: _enterFullscreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 全屏视频播放页面
/// 共享主页面的 Player，进入时切换横屏+沉浸式模式，退出时恢复
class _FullscreenVideoPage extends StatefulWidget {
  final Player player;
  final VideoController videoController;
  final bool isCompleted;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onReplay;
  final ValueChanged<bool> onCompletedChanged;

  const _FullscreenVideoPage({
    required this.player,
    required this.videoController,
    required this.isCompleted,
    required this.onPlayPause,
    required this.onSeek,
    required this.onReplay,
    required this.onCompletedChanged,
  });

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  bool _showControls = true;
  bool _isCompleted = false;
  Timer? _hideControlsTimer;
  StreamSubscription<bool>? _completedSub;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    _completedSub = widget.player.stream.completed.listen((completed) {
      if (completed && mounted) {
        setState(() {
          _isCompleted = true;
        });
        widget.onCompletedChanged(true);
      }
    });
    _enterFullscreenMode();
    if (widget.player.state.playing) {
      _startHideControlsTimer();
    }
  }

  Future<void> _enterFullscreenMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _exitFullscreenMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _completedSub?.cancel();
    _exitFullscreenMode();
    super.dispose();
  }

  void _onTapVideo() {
    if (_isCompleted) return;

    if (_showControls) {
      _hideControlsTimer?.cancel();
      setState(() {
        _showControls = false;
      });
    } else {
      _resetHideControlsTimer();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.player.state.playing) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _resetHideControlsTimer() {
    setState(() {
      _showControls = true;
    });
    _startHideControlsTimer();
  }

  Future<void> _handlePlayPause() async {
    widget.onPlayPause();
    _resetHideControlsTimer();
    if (mounted) setState(() {});
  }

  Future<void> _handleReplay() async {
    widget.onReplay();
    setState(() {
      _isCompleted = false;
    });
    widget.onCompletedChanged(false);
    _resetHideControlsTimer();
  }

  void _exitFullscreen() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) return;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Video(
                controller: widget.videoController,
                controls: NoVideoControls,
              ),

              // 缓冲指示器
              StreamBuilder<bool>(
                stream: widget.player.stream.buffering,
                initialData: widget.player.state.buffering,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white70,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // 播放控件 overlay
              GestureDetector(
                onTap: _onTapVideo,
                behavior: HitTestBehavior.opaque,
                child: VideoControlsOverlay(
                  player: widget.player,
                  showControls: _showControls,
                  isCompleted: _isCompleted,
                  isFullscreen: true,
                  onPlayPause: _handlePlayPause,
                  onSeek: widget.onSeek,
                  onReplay: _handleReplay,
                  onSliderDragStart: () => _hideControlsTimer?.cancel(),
                  onSliderDragEnd: () => _startHideControlsTimer(),
                  onToggleFullscreen: _exitFullscreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
