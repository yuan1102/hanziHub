import 'package:flutter/material.dart';

import '../models/character_entry.dart';
import '../repositories/character_repository.dart';
import '../utils/filter.dart';
import '../widgets/character_card.dart';
import 'settings_page.dart';
import 'video_player_page.dart';

class CharacterListPage extends StatefulWidget {
  final CharacterRepository repository;

  const CharacterListPage({super.key, required this.repository});

  @override
  State<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<CharacterListPage>
    with SingleTickerProviderStateMixin {
  List<CharacterEntry> _allCharacters = [];
  String _query = '';
  bool _loading = true;

  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    try {
      final characters = await widget.repository.loadCharacters();
      setState(() {
        _allCharacters = characters;
        _loading = false;
      });
    } catch (e) {
      debugPrint('加载汉字失败: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  List<CharacterEntry> get _filtered => filter(_allCharacters, _query);
  List<CharacterEntry> get _unlearned =>
      _filtered.where((c) => c.learnStatus == LearnStatus.unlearned).toList();
  List<CharacterEntry> get _learned =>
      _filtered.where((c) => c.learnStatus == LearnStatus.learned).toList();
  List<CharacterEntry> get _mastered =>
      _filtered.where((c) => c.learnStatus == LearnStatus.mastered).toList();

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  Future<void> _toggleLearnedStatus(CharacterEntry entry) async {
    // 循环：未学习 → 已学习 → 已掌握 → 未学习
    final LearnStatus newStatus;
    final String label;
    switch (entry.learnStatus) {
      case LearnStatus.unlearned:
        newStatus = LearnStatus.learned;
        label = '已学习';
      case LearnStatus.learned:
        newStatus = LearnStatus.mastered;
        label = '已掌握';
      case LearnStatus.mastered:
        newStatus = LearnStatus.unlearned;
        label = '未学习';
    }

    await widget.repository
        .updateCharacterStatus(entry.name, status: newStatus);

    setState(() {
      final index = _allCharacters.indexWhere((e) => e.name == entry.name);
      if (index != -1) {
        _allCharacters[index] =
            _allCharacters[index].copyWith(learnStatus: newStatus);
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('「${entry.name}」已标记为$label'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('汉字学习'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(repository: widget.repository),
                ),
              );
              _loadCharacters();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '搜索汉字...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGrid(_unlearned, emptyHint: '所有汉字都已学习！'),
                _buildGrid(_learned, emptyHint: '还没有已学习的汉字'),
                _buildGrid(_mastered, emptyHint: '还没有已掌握的汉字'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
        child: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.school_outlined),
              text: '未学习 (${_unlearned.length})',
            ),
            Tab(
              icon: const Icon(Icons.menu_book),
              text: '已学习 (${_learned.length})',
            ),
            Tab(
              icon: const Icon(Icons.star),
              text: '已掌握 (${_mastered.length})',
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<CharacterEntry> characters,
      {required String emptyHint}) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allCharacters.isEmpty) {
      return const Center(child: Text('暂无可学习的汉字'));
    }

    if (characters.isEmpty) {
      return Center(child: Text(emptyHint));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return CharacterCard(
          character: character,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerPage(entry: character),
              ),
            );
          },
          onLongPress: () => _toggleLearnedStatus(character),
        );
      },
    );
  }
}
