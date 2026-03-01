import 'package:flutter/material.dart';
import '../models/character_entry.dart';

class CharacterCard extends StatelessWidget {
  final CharacterEntry character;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
    this.onLongPress,
  });

  Color get _cardColor {
    switch (character.learnStatus) {
      case LearnStatus.unlearned:
        return const Color(0xFFFFF9C4); // 淡黄色
      case LearnStatus.learned:
        return const Color(0xFFC8E6C9); // 淡绿色
      case LearnStatus.mastered:
        return const Color(0xFFBBDEFB); // 淡蓝色
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: _cardColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    character.tonedPinyin,
                    style: TextStyle(
                      fontSize: size * 0.16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: size * 0.02),
                  Text(
                    character.name,
                    style: TextStyle(
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
