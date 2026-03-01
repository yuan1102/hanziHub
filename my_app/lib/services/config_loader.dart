import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// 汉字配置数据模型
class HanziConfigItem {
  final String name;         // 汉字，如 "绿"
  final String pinyin;       // 拼音，如 "lü"
  final int? tone;           // 声调数字（1-4）
  final String meaning;      // 含义
  final String videoFile;    // 视频文件名，如 "绿.mp4"
  final String videoSource;  // 'remote'、'external' 或 'builtin'
  final String? videoUrl;    // 远程视频 URL（当 videoSource='remote' 时）
  final double? duration;    // 视频时长（秒）
  final String? fileSize;    // 文件大小

  HanziConfigItem({
    required this.name,
    required this.pinyin,
    this.tone,
    required this.meaning,
    required this.videoFile,
    required this.videoSource,
    this.videoUrl,
    this.duration,
    this.fileSize,
  });

  factory HanziConfigItem.fromJson(Map<String, dynamic> json) {
    return HanziConfigItem(
      name: json['name'] as String,
      pinyin: json['pinyin'] as String,
      tone: json['tone'] as int?,
      meaning: json['meaning'] as String? ?? '',
      videoFile: json['videoFile'] as String,
      videoSource: json['videoSource'] as String? ?? 'external',
      videoUrl: json['videoUrl'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      fileSize: json['fileSize'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'pinyin': pinyin,
    'tone': tone,
    'meaning': meaning,
    'videoFile': videoFile,
    'videoSource': videoSource,
    if (videoUrl != null) 'videoUrl': videoUrl,
    'duration': duration,
    'fileSize': fileSize,
  };
}

/// 汉字配置加载器
class ConfigLoader {
  static const String _configPath = 'assets/config/hanzi_config.json';
  // GitHub 线上配置 URL
  static const String _remoteConfigUrl =
      'https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/hanzi_config.json';
  static const String _localCacheFileName = 'hanzi_config_cache.json';
  static const Duration _cacheExpiry = Duration(hours: 24); // 24小时缓存过期

  /// 加载汉字列表（优先线上 → 本地缓存 → 内置配置）
  static Future<List<HanziConfigItem>> loadConfig() async {
    try {
      // 1. 尝试从线上获取
      final remoteConfig = await _loadRemoteConfig();
      if (remoteConfig.isNotEmpty) {
        debugPrint('✓ 使用线上配置（${remoteConfig.length} 个汉字）');
        return remoteConfig;
      }
    } catch (e) {
      debugPrint('线上配置加载失败，尝试本地缓存: $e');
    }

    try {
      // 2. 尝试从本地缓存加载
      final cachedConfig = await _loadCachedConfig();
      if (cachedConfig.isNotEmpty) {
        debugPrint('✓ 使用本地缓存配置（${cachedConfig.length} 个汉字）');
        return cachedConfig;
      }
    } catch (e) {
      debugPrint('本地缓存加载失败: $e');
    }

    try {
      // 3. 回退到内置配置
      final builtInConfig = await _loadBuiltInConfig();
      if (builtInConfig.isNotEmpty) {
        debugPrint('✓ 使用内置配置（${builtInConfig.length} 个汉字）');
        return builtInConfig;
      }
    } catch (e) {
      debugPrint('内置配置加载失败: $e');
    }

    return [];
  }

  /// 从线上 GitHub 获取配置
  static Future<List<HanziConfigItem>> _loadRemoteConfig() async {
    try {
      debugPrint('正在获取线上配置...');

      final response = await http.get(Uri.parse(_remoteConfigUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('线上配置获取超时'),
      );

      if (response.statusCode != 200) {
        throw Exception('线上配置获取失败: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final charactersList = json['characters'] as List<dynamic>? ?? [];

      final config = charactersList
          .map((item) => HanziConfigItem.fromJson(item as Map<String, dynamic>))
          .toList();

      // 保存到本地缓存
      if (config.isNotEmpty) {
        await _saveCachedConfig(response.body);
      }

      return config;
    } catch (e) {
      rethrow;
    }
  }

  /// 从本地缓存加载配置
  static Future<List<HanziConfigItem>> _loadCachedConfig() async {
    try {
      final cacheFile = await _getCacheFile();

      if (!await cacheFile.exists()) {
        return [];
      }

      // 检查缓存是否过期
      final lastModified = await cacheFile.lastModified();
      if (DateTime.now().difference(lastModified) > _cacheExpiry) {
        debugPrint('本地缓存已过期');
        return [];
      }

      final jsonString = await cacheFile.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final charactersList = json['characters'] as List<dynamic>? ?? [];
      return charactersList
          .map((item) => HanziConfigItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 从内置配置加载
  static Future<List<HanziConfigItem>> _loadBuiltInConfig() async {
    try {
      final jsonString = await rootBundle.loadString(_configPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final charactersList = json['characters'] as List<dynamic>? ?? [];
      return charactersList
          .map((item) => HanziConfigItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 保存配置到本地缓存
  static Future<void> _saveCachedConfig(String jsonString) async {
    try {
      final cacheFile = await _getCacheFile();
      await cacheFile.writeAsString(jsonString);
      debugPrint('✓ 配置已缓存');
    } catch (e) {
      debugPrint('保存配置缓存失败: $e');
    }
  }

  /// 获取缓存文件路径
  static Future<File> _getCacheFile() async {
    final docDir = await getApplicationDocumentsDirectory();
    return File('${docDir.path}/$_localCacheFileName');
  }

  /// 清除本地缓存
  static Future<void> clearCache() async {
    try {
      final cacheFile = await _getCacheFile();
      if (await cacheFile.exists()) {
        await cacheFile.delete();
        debugPrint('✓ 配置缓存已清除');
      }
    } catch (e) {
      debugPrint('清除缓存失败: $e');
    }
  }

  /// 获取配置版本号
  static Future<String> getConfigVersion() async {
    try {
      final jsonString = await rootBundle.loadString(_configPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json['version'] as String? ?? '1.0.0';
    } catch (e) {
      return '1.0.0';
    }
  }

  /// 按汉字名称查找配置
  static Future<HanziConfigItem?> findByName(String name) async {
    final config = await loadConfig();
    try {
      return config.firstWhere((item) => item.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 按拼音查找配置
  static Future<HanziConfigItem?> findByPinyin(String pinyin) async {
    final config = await loadConfig();
    try {
      return config.firstWhere((item) => item.pinyin == pinyin);
    } catch (e) {
      return null;
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
