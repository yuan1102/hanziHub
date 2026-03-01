import '../repositories/character_repository.dart';

enum VideoSource { builtIn, userUploaded }

enum LearnStatus { unlearned, learned, mastered }

class CharacterEntry {
  final String name;
  final String pinyin;
  final VideoSource videoSource;
  final LearnStatus learnStatus;

  const CharacterEntry({
    required this.name,
    required this.pinyin,
    required this.videoSource,
    this.learnStatus = LearnStatus.unlearned,
  });

  CharacterEntry copyWith({LearnStatus? learnStatus}) => CharacterEntry(
        name: name,
        pinyin: pinyin,
        videoSource: videoSource,
        learnStatus: learnStatus ?? this.learnStatus,
      );

  String get tonedPinyin => getTonedPinyinFromChar(name);

  String get videoPath {
    switch (videoSource) {
      case VideoSource.builtIn:
        return 'assets/mp4/$name.mp4';
      case VideoSource.userUploaded:
        return '$name.mp4';
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'pinyin': pinyin,
        'videoSource': videoSource.name,
        'learnStatus': learnStatus.name,
      };

  factory CharacterEntry.fromJson(Map<String, dynamic> json) {
    LearnStatus status;
    if (json.containsKey('learnStatus')) {
      status = LearnStatus.values.byName(json['learnStatus'] as String);
    } else {
      final learned = json['learned'] as bool? ?? false;
      status = learned ? LearnStatus.mastered : LearnStatus.unlearned;
    }
    return CharacterEntry(
      name: json['name'] as String,
      pinyin: json['pinyin'] as String,
      videoSource: VideoSource.values.byName(json['videoSource'] as String),
      learnStatus: status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterEntry &&
          name == other.name &&
          videoSource == other.videoSource;

  @override
  int get hashCode => Object.hash(name, videoSource);
}
