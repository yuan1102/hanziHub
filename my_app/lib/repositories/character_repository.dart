import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';

import '../models/character_entry.dart';

abstract class CharacterRepository {
  Future<List<CharacterEntry>> loadCharacters();
  Future<void> addCharacter(CharacterEntry entry);
  Future<void> deleteCharacter(CharacterEntry entry);
  Future<void> updateCharacterStatus(String name, {required LearnStatus status});
}

class PersistentCharacterRepository implements CharacterRepository {
  final String docDir;

  PersistentCharacterRepository(this.docDir);

  String get _jsonPath => '$docDir/characters.json';

  @override
  Future<List<CharacterEntry>> loadCharacters() async {
    // 从 JSON 读取已有数据（用于保留学习状态和用户上传条目）
    final savedEntries = <CharacterEntry>[];
    final file = File(_jsonPath);
    try {
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content) as List<dynamic>;
        for (final e in jsonList) {
          savedEntries.add(
              CharacterEntry.fromJson(e as Map<String, dynamic>));
        }
      }
    } catch (e, st) {
      debugPrint('读取 characters.json 失败: $e');
      debugPrint('$st');
    }

    // 内置视频始终从 AssetManifest 实时扫描，确保与 assets 目录同步
    final scannedBuiltIn = await _scanBuiltInVideos();

    // 合并：内置视频用扫描结果，但保留 JSON 中已有的学习状态
    final builtInEntries = scannedBuiltIn.map((scanned) {
      final saved = savedEntries
          .where((s) => s.name == scanned.name && s.videoSource == VideoSource.builtIn)
          .firstOrNull;
      if (saved != null && saved.learnStatus != LearnStatus.unlearned) {
        return scanned.copyWith(learnStatus: saved.learnStatus);
      }
      return scanned;
    }).toList();

    // 用户上传条目从 JSON 中恢复
    final userEntries = savedEntries
        .where((e) => e.videoSource == VideoSource.userUploaded)
        .toList();

    final allEntries = [...builtInEntries, ...userEntries];
    await _writeJson(allEntries);
    return allEntries;
  }

  @override
  Future<void> addCharacter(CharacterEntry entry) async {
    final entries = await loadCharacters();
    if (entries.any((e) => e.name == entry.name)) {
      throw Exception('汉字「${entry.name}」已存在');
    }
    entries.add(entry);
    await _writeJson(entries);
  }

  @override
  Future<void> deleteCharacter(CharacterEntry entry) async {
    if (entry.videoSource == VideoSource.builtIn) {
      throw Exception('不允许删除内置汉字条目');
    }
    final entries = await loadCharacters();
    entries.removeWhere((e) => e == entry);
    await _writeJson(entries);

    // Delete the local video file
    final videoFile = File('$docDir/${entry.videoPath}');
    if (await videoFile.exists()) {
      await videoFile.delete();
    }
  }

  @override
  Future<void> updateCharacterStatus(String name,
      {required LearnStatus status}) async {
    final file = File(_jsonPath);
    if (!await file.exists()) return;

    final content = await file.readAsString();
    final List<dynamic> jsonList = json.decode(content) as List<dynamic>;
    final entries = jsonList
        .map((e) => CharacterEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    final index = entries.indexWhere((e) => e.name == name);
    if (index == -1) return;

    entries[index] = entries[index].copyWith(learnStatus: status);
    await _writeJson(entries);
  }

  Future<List<CharacterEntry>> _scanBuiltInVideos() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      debugPrint('AssetManifest 总资源数: ${allAssets.length}');

      final mp4Assets = allAssets
          .where((k) => k.startsWith('assets/mp4/') && k.endsWith('.mp4'))
          .toList();
      debugPrint('扫描到 MP4 资源数: ${mp4Assets.length}');
      if (mp4Assets.isNotEmpty) {
        debugPrint('首个 MP4 路径: ${mp4Assets.first}');
      }

      final entries = <CharacterEntry>[];
      for (final k in mp4Assets) {
        try {
          final name =
              k.replaceFirst('assets/mp4/', '').replaceAll('.mp4', '');
          final pinyin = getPinyinFromChar(name);
          entries.add(CharacterEntry(
            name: name,
            pinyin: pinyin,
            videoSource: VideoSource.builtIn,
          ));
        } catch (e) {
          debugPrint('解析资源 $k 失败: $e');
        }
      }
      return entries;
    } catch (e, st) {
      debugPrint('扫描 AssetManifest 失败: $e');
      debugPrint('$st');
      return [];
    }
  }

  Future<void> _writeJson(List<CharacterEntry> entries) async {
    final file = File(_jsonPath);
    final jsonString =
        const JsonEncoder.withIndent('  ').convert(
          entries.map((e) => e.toJson()).toList(),
        );
    await file.writeAsString(jsonString);
  }
}

/// 根据汉字获取拼音（不带声调，用于搜索和 key）
String getPinyinFromChar(String character) {
  return PinyinHelper.getPinyin(character,
      separator: '', format: PinyinFormat.WITHOUT_TONE).toLowerCase();
}

/// 根据汉字获取带声调的拼音（用于显示）
String getTonedPinyinFromChar(String character) {
  return PinyinHelper.getPinyin(character,
      separator: '', format: PinyinFormat.WITH_TONE_MARK).toLowerCase();
}
