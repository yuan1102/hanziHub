import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// 视频缓存管理器
/// 管理远程视频的本地缓存，避免重复下载
class VideoCacheManager {
  static const String _cacheDir = 'video_cache';

  /// 获取缓存目录
  static Future<Directory> _getCacheDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${docDir.path}/$_cacheDir');

    // 如果目录不存在，创建它
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDir;
  }

  /// 获取视频的本地缓存路径
  /// [videoUrl] 远程视频 URL
  /// 返回本地缓存文件路径
  static Future<String> getCachePath(String videoUrl) async {
    final cacheDir = await _getCacheDirectory();
    // 使用 URL 的 hash 作为文件名，避免特殊字符问题
    final fileName = _getFileName(videoUrl);
    return '${cacheDir.path}/$fileName';
  }

  /// 从 URL 生成唯一的文件名
  static String _getFileName(String url) {
    // 提取文件名（如 "绿.mp4"）
    final fileName = url.split('/').last;
    return fileName;
  }

  /// 检查视频是否已缓存
  /// [videoUrl] 远程视频 URL
  /// 返回 true 如果视频已缓存，false 否则
  static Future<bool> isCached(String videoUrl) async {
    try {
      final cachePath = await getCachePath(videoUrl);
      final file = File(cachePath);
      return await file.exists();
    } catch (e) {
      debugPrint('检查缓存失败: $e');
      return false;
    }
  }

  /// 下载并缓存视频（立即返回，边下边播）
  /// [videoUrl] 远程视频 URL
  /// 返回本地缓存文件路径
  /// 如果视频已缓存，直接返回；否则开始下载并立即返回临时路径
  static Future<String?> getOrDownloadVideo(
    String videoUrl, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final cachePath = await getCachePath(videoUrl);
      final file = File(cachePath);

      // 如果已缓存，直接返回
      if (await file.exists()) {
        debugPrint('视频已缓存: $videoUrl');
        return cachePath;
      }

      debugPrint('开始下载视频（边下边播）: $videoUrl');

      // 异步下载，但立即返回路径以支持边下边播
      _downloadVideoInBackground(videoUrl);

      // 立即返回缓存路径，让播放器等待文件
      return cachePath;
    } catch (e) {
      debugPrint('处理视频失败: $e');
      return null;
    }
  }

  /// 后台下载视频（支持边下边播）
  static Future<void> _downloadVideoInBackground(String videoUrl) async {
    try {
      final cachePath = await getCachePath(videoUrl);
      final file = File(cachePath);

      // 再次检查（并发保护）
      if (await file.exists()) {
        debugPrint('视频已存在: $videoUrl');
        return;
      }

      // 创建临时文件用于下载
      final tempFile = File('$cachePath.tmp');

      // 获取视频总大小
      final headResponse = await http
          .head(Uri.parse(videoUrl))
          .timeout(const Duration(minutes: 5));

      final contentLength = int.tryParse(
            headResponse.headers['content-length'] ?? '0',
          ) ??
          0;

      debugPrint('视频大小: ${_formatBytes(contentLength)}');

      // 流式下载视频
      final request = http.Request('GET', Uri.parse(videoUrl));
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw TimeoutException('视频下载超时'),
      );

      if (streamedResponse.statusCode != 200) {
        throw Exception('下载失败: ${streamedResponse.statusCode}');
      }

      // 边下边保存
      final bytes = <int>[];
      var received = 0;

      await streamedResponse.stream.listen(
        (List<int> chunk) {
          bytes.addAll(chunk);
          received += chunk.length;

          // 定期保存到临时文件，支持边下边播
          if (received % (1024 * 100) == 0) {
            // 每 100KB 保存一次
            _savePartialVideo(tempFile, bytes);
          }
        },
      ).asFuture<void>();

      // 保存完整视频
      await tempFile.writeAsBytes(bytes);

      // 重命名为最终文件
      await tempFile.rename(cachePath);

      debugPrint('视频下载完成: $cachePath');
    } catch (e) {
      debugPrint('后台下载失败: $e');
      // 删除不完整的临时文件
      try {
        final cachePath = await getCachePath(videoUrl);
        final tempFile = File('$cachePath.tmp');
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
    }
  }

  /// 保存部分视频（用于边下边播）
  static void _savePartialVideo(File file, List<int> bytes) {
    try {
      file.writeAsBytesSync(bytes);
    } catch (e) {
      debugPrint('保存部分视频失败: $e');
    }
  }

  /// 流式下载视频（支持进度回调）
  /// [videoUrl] 远程视频 URL
  /// [onProgress] 进度回调：(已下载字节数, 总字节数)
  /// 返回本地缓存文件路径
  static Future<String?> downloadVideoWithProgress(
    String videoUrl, {
    required void Function(int received, int total) onProgress,
  }) async {
    try {
      final cachePath = await getCachePath(videoUrl);
      final file = File(cachePath);

      // 如果已缓存，直接返回
      if (await file.exists()) {
        debugPrint('视频已缓存: $videoUrl');
        return cachePath;
      }

      debugPrint('开始下载视频（带进度）: $videoUrl');

      final uri = Uri.parse(videoUrl);
      final request = http.Request('GET', uri);

      final response = await request.send().timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw TimeoutException('视频下载超时'),
      );

      if (response.statusCode != 200) {
        throw Exception('下载失败: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final bytes = <int>[];
      var received = 0;

      await response.stream.listen(
        (List<int> chunk) {
          bytes.addAll(chunk);
          received += chunk.length;
          onProgress(received, contentLength);
        },
      ).asFuture<void>();

      // 保存到本地
      await file.writeAsBytes(bytes);
      debugPrint('视频已缓存: $cachePath');

      return cachePath;
    } catch (e) {
      debugPrint('下载视频失败: $e');
      return null;
    }
  }

  /// 删除缓存的视频
  /// [videoUrl] 远程视频 URL
  static Future<bool> clearCache(String videoUrl) async {
    try {
      final cachePath = await getCachePath(videoUrl);
      final file = File(cachePath);

      if (await file.exists()) {
        await file.delete();
        debugPrint('已删除视频缓存: $cachePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('删除缓存失败: $e');
      return false;
    }
  }

  /// 清空所有视频缓存
  static Future<bool> clearAllCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('已清空所有视频缓存');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('清空缓存失败: $e');
      return false;
    }
  }

  /// 获取缓存大小（字节）
  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      final files = cacheDir.listSync();

      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('获取缓存大小失败: $e');
      return 0;
    }
  }

  /// 获取格式化的缓存大小
  static Future<String> getFormattedCacheSize() async {
    final bytes = await getCacheSize();
    return _formatBytes(bytes);
  }

  /// 格式化字节数
  static String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// 列出所有缓存的视频
  static Future<List<String>> listCachedVideos() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return [];
      }

      final files = cacheDir.listSync();
      return files
          .where((f) => f is File)
          .map((f) => f.path.split('/').last)
          .toList();
    } catch (e) {
      debugPrint('列出缓存失败: $e');
      return [];
    }
  }
}

/// 超时异常
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
