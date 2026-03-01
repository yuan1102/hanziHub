import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/character_entry.dart';
import '../repositories/character_repository.dart';

/// 设置页面：管理汉字条目，支持添加和删除用户上传条目
/// 需求：5.1–5.7, 6.1–6.5
class SettingsPage extends StatefulWidget {
  final CharacterRepository repository;

  const SettingsPage({super.key, required this.repository});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<CharacterEntry> _characters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    try {
      final characters = await widget.repository.loadCharacters();
      setState(() {
        _characters = characters;
        _loading = false;
      });
    } catch (e) {
      debugPrint('加载汉字失败: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    String generatedPinyin = '';
    String generatedTonedPinyin = '';
    String? selectedFilePath;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('添加汉字'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '汉字'),
                  maxLength: 1,
                  onChanged: (value) {
                    final char = value.trim();
                    if (char.isNotEmpty) {
                      setDialogState(() {
                        generatedPinyin = getPinyinFromChar(char);
                        generatedTonedPinyin = getTonedPinyinFromChar(char);
                      });
                    } else {
                      setDialogState(() {
                        generatedPinyin = '';
                        generatedTonedPinyin = '';
                      });
                    }
                  },
                ),
                if (generatedTonedPinyin.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Text('拼音：', style: TextStyle(color: Colors.grey)),
                        Text(
                          generatedTonedPinyin,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedFilePath != null
                            ? selectedFilePath!.split('/').last
                            : '未选择文件',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['mp4'],
                        );
                        if (result != null && result.files.single.path != null) {
                          setDialogState(() {
                            selectedFilePath = result.files.single.path;
                          });
                        }
                      },
                      child: const Text('选择视频'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();

                if (name.isEmpty) {
                  _showSnackBar('请输入汉字');
                  return;
                }
                if (generatedPinyin.isEmpty) {
                  _showSnackBar('无法识别该汉字的拼音');
                  return;
                }
                if (selectedFilePath == null) {
                  _showSnackBar('请选择一个视频文件');
                  return;
                }
                if (!selectedFilePath!.toLowerCase().endsWith('.mp4')) {
                  _showSnackBar('仅支持 mp4 格式');
                  return;
                }
                if (_characters.any((e) => e.name == name)) {
                  _showSnackBar('该汉字已存在');
                  return;
                }

                try {
                  final docDir = await getApplicationDocumentsDirectory();
                  final destPath = '${docDir.path}/$name.mp4';
                  await File(selectedFilePath!).copy(destPath);

                  final entry = CharacterEntry(
                    name: name,
                    pinyin: generatedPinyin,
                    videoSource: VideoSource.userUploaded,
                  );
                  await widget.repository.addCharacter(entry);

                  if (ctx.mounted) Navigator.pop(ctx);
                  await _loadCharacters();
                } catch (e) {
                  _showSnackBar('添加失败: $e');
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(CharacterEntry entry) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${entry.name}」吗？视频文件也将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _characters.isEmpty
              ? const Center(child: Text('暂无汉字条目'))
              : ListView.builder(
                  itemCount: _characters.length,
                  itemBuilder: (context, index) {
                    final entry = _characters[index];
                    final isUserUploaded =
                        entry.videoSource == VideoSource.userUploaded;

                    final tile = Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              entry.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${entry.tonedPinyin})',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isUserUploaded
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isUserUploaded ? '用户上传' : '内置',
                            style: TextStyle(
                              fontSize: 12,
                              color: isUserUploaded
                                  ? Colors.blue.shade800
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    );

                    if (!isUserUploaded) return tile;

                    return Dismissible(
                      key: ValueKey(entry),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Colors.red,
                        child:
                            const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _confirmDelete(entry),
                      onDismissed: (_) async {
                        try {
                          await widget.repository.deleteCharacter(entry);
                          await _loadCharacters();
                        } catch (e) {
                          _showSnackBar('删除失败: $e');
                          await _loadCharacters();
                        }
                      },
                      child: tile,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: '添加汉字',
        child: const Icon(Icons.add),
      ),
    );
  }
}
