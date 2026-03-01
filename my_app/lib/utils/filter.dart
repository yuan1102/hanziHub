import '../models/character_entry.dart';

/// 根据查询词过滤汉字列表。
///
/// - 若 [query] 为空，返回全部 [characters]。
/// - 若 [query] 非空，返回汉字名称或拼音包含 [query] 的条目列表。
///
/// 需求：1.1、2.2、2.3
List<CharacterEntry> filter(List<CharacterEntry> characters, String query) {
  if (query.isEmpty) return characters;
  return characters
      .where((c) => c.name.contains(query) || c.pinyin.contains(query))
      .toList();
}
