import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

import 'pages/character_list_page.dart';
import 'repositories/character_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final docDir = await getApplicationDocumentsDirectory();
  runApp(MyApp(docDir: docDir.path));
}

class MyApp extends StatelessWidget {
  final String docDir;

  const MyApp({super.key, required this.docDir});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '汉字学习',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: CharacterListPage(
        repository: PersistentCharacterRepository(docDir),
      ),
    );
  }
}
