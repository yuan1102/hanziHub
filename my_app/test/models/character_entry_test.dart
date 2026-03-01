import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/character_entry.dart';

void main() {
  group('VideoSource', () {
    test('has builtIn and userUploaded values', () {
      expect(VideoSource.values, contains(VideoSource.builtIn));
      expect(VideoSource.values, contains(VideoSource.userUploaded));
      expect(VideoSource.values.length, 2);
    });
  });

  group('CharacterEntry', () {
    test('stores name, pinyin, and videoSource', () {
      const entry = CharacterEntry(
        name: '苗',
        pinyin: 'miao',
        videoSource: VideoSource.builtIn,
      );
      expect(entry.name, '苗');
      expect(entry.pinyin, 'miao');
      expect(entry.videoSource, VideoSource.builtIn);
    });

    test('videoPath returns asset path for builtIn', () {
      const entry = CharacterEntry(
        name: '苗',
        pinyin: 'miao',
        videoSource: VideoSource.builtIn,
      );
      expect(entry.videoPath, 'assets/mp4/miao.mp4');
    });

    test('videoPath returns local filename for userUploaded', () {
      const entry = CharacterEntry(
        name: '自定义',
        pinyin: 'custom',
        videoSource: VideoSource.userUploaded,
      );
      expect(entry.videoPath, 'custom.mp4');
    });

    test('toJson produces correct map', () {
      const entry = CharacterEntry(
        name: '田',
        pinyin: 'tian',
        videoSource: VideoSource.builtIn,
      );
      final json = entry.toJson();
      expect(json, {
        'name': '田',
        'pinyin': 'tian',
        'videoSource': 'builtIn',
      });
    });

    test('fromJson reconstructs entry correctly', () {
      final json = {
        'name': '田',
        'pinyin': 'tian',
        'videoSource': 'builtIn',
      };
      final entry = CharacterEntry.fromJson(json);
      expect(entry.name, '田');
      expect(entry.pinyin, 'tian');
      expect(entry.videoSource, VideoSource.builtIn);
    });

    test('toJson/fromJson roundtrip preserves equality', () {
      const original = CharacterEntry(
        name: '苗',
        pinyin: 'miao',
        videoSource: VideoSource.userUploaded,
      );
      final restored = CharacterEntry.fromJson(original.toJson());
      expect(restored, original);
    });

    test('equality works for identical fields', () {
      const a = CharacterEntry(
        name: '苗',
        pinyin: 'miao',
        videoSource: VideoSource.builtIn,
      );
      const b = CharacterEntry(
        name: '苗',
        pinyin: 'miao',
        videoSource: VideoSource.builtIn,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when fields differ', () {
      const a = CharacterEntry(
        name: '苗',
        pinyin: 'miao',
        videoSource: VideoSource.builtIn,
      );
      const b = CharacterEntry(
        name: '田',
        pinyin: 'tian',
        videoSource: VideoSource.builtIn,
      );
      expect(a, isNot(b));
    });

    test('inequality when videoSource differs', () {
      const a = CharacterEntry(
        name: '苗',
        pinyin: 'miao',
        videoSource: VideoSource.builtIn,
      );
      const b = CharacterEntry(
        name: '苗',
        pinyin: 'miao',
        videoSource: VideoSource.userUploaded,
      );
      expect(a, isNot(b));
    });
  });
}
