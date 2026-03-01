# 汉字Hub 系统架构

## 概述

汉字Hub 采用**配置驱动 + 外部存储**的架构，支持灵活的汉字库管理和视频资源加载。

```
┌─────────────────────────────────────────────────────────────┐
│                     项目根目录 (GitHub)                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  📄 hanzi_config.json          ← 主配置文件（维护汉字元数据） │
│  📁 mp4/                       ← 外部视频存储                 │
│      ├── 绿.mp4                                               │
│      ├── 树.mp4                                               │
│      └── ...                                                  │
│                                                               │
│  📁 my_app/                    ← Flutter 应用                │
│      ├── lib/                                                 │
│      │   ├── services/                                       │
│      │   │   └── config_loader.dart    ← 配置加载器        │
│      │   ├── repositories/                                   │
│      │   │   └── character_repository.dart  ← 数据仓库      │
│      │   └── ...                                             │
│      │                                                        │
│      └── assets/                                             │
│          ├── config/                                         │
│          │   └── hanzi_config.json   ← 配置副本（打包时）  │
│          ├── mp4/                                            │
│          │   └── ...               ← 内置视频（可选）       │
│          └── icon/                                           │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## 核心模块

### 1. ConfigLoader（配置加载器）

**文件**：`my_app/lib/services/config_loader.dart`

**职责**：
- 从应用资源加载 `hanzi_config.json`
- 提供查询接口（按汉字名、拼音查找）
- 版本号管理

**关键 API**：
```dart
class ConfigLoader {
  static Future<List<HanziConfigItem>> loadConfig()
  static Future<String> getConfigVersion()
  static Future<HanziConfigItem?> findByName(String name)
  static Future<HanziConfigItem?> findByPinyin(String pinyin)
}
```

### 2. CharacterRepository（数据仓库）

**文件**：`my_app/lib/repositories/character_repository.dart`

**职责**：
- 持久化用户学习状态
- 管理本地和用户上传视频
- 与配置加载器协作

**特点**：
- 从 ConfigLoader 加载基础数据
- 将学习状态保存到 `characters.json`
- 支持添加/删除用户自定义汉字

### 3. 数据模型

**文件**：`my_app/lib/models/character_entry.dart`

包含三个关键数据结构：

#### HanziConfigItem
来自配置文件的静态信息：
```dart
class HanziConfigItem {
  final String name;
  final String pinyin;
  final int? tone;
  final String meaning;
  final String videoFile;
  final String videoSource; // "external" 或 "builtin"
  final double? duration;
  final String? fileSize;
}
```

#### CharacterEntry
应用运行时的汉字条目（包含学习状态）：
```dart
class CharacterEntry {
  final String name;
  final String pinyin;
  final VideoSource videoSource;
  final LearnStatus learnStatus; // 未学习/已学习/已掌握
}
```

#### LearnStatus 枚举
```dart
enum LearnStatus { unlearned, learned, mastered }
```

## 数据流

### 应用启动流程

```
1. main.dart 启动
    ↓
2. 初始化 PersistentCharacterRepository
    ↓
3. CharacterListPage 调用 loadCharacters()
    ↓
4. Repository 执行：
    a) 加载 characters.json（如果存在）← 学习状态
    b) 调用 ConfigLoader.loadConfig()    ← 汉字元数据
    c) 合并数据：配置 + 学习状态
    d) 返回 List<CharacterEntry>
    ↓
5. UI 显示汉字卡片
```

### 添加新汉字流程（用户操作）

```
用户在设置页 → 点击"添加汉字"
    ↓
弹出表单（输入汉字名、拼音）
    ↓
用户选择视频文件
    ↓
应用复制视频到本地存储
    ↓
创建 CharacterEntry（videoSource=userUploaded）
    ↓
Repository.addCharacter() 保存到 characters.json
    ↓
返回列表页，显示新汉字
```

### 播放视频流程

```
用户点击汉字卡片
    ↓
VideoPlayerPage 收到 CharacterEntry
    ↓
判断 videoSource 类型：
    ├─ "external" 或 "builtin" ← ConfigLoader 来源
    │    └─> 加载：assets/mp4/{videoFile}
    │
    └─ "userUploaded"
         └─> 加载：$docDir/{videoFile}
    ↓
VideoPlayerController 初始化
    ↓
视频播放
```

## 文件清单

### 配置文件

| 路径 | 说明 | 维护方式 |
|------|------|----------|
| `/hanzi_config.json` | 项目根目录的主配置 | 手工编辑 + Git 版本控制 |
| `/my_app/assets/config/hanzi_config.json` | 应用资源中的配置副本 | 同步复制（构建前） |

### Dart 代码

| 文件 | 职责 |
|------|------|
| `lib/services/config_loader.dart` | 配置加载和查询 |
| `lib/models/character_entry.dart` | 数据模型定义 |
| `lib/repositories/character_repository.dart` | 数据持久化和业务逻辑 |
| `lib/pages/character_list_page.dart` | 汉字列表主页 |
| `lib/pages/video_player_page.dart` | 视频播放器 |
| `lib/pages/settings_page.dart` | 设置和汉字管理 |

### 资源文件

| 路径 | 说明 |
|------|------|
| `/mp4/` | 外部视频库（中文命名） |
| `/my_app/assets/mp4/` | 应用内置视频（可选） |
| `/my_app/assets/icon/` | 应用图标资源 |

## 技术栈

| 层 | 技术 | 用途 |
|----|------|------|
| **UI 框架** | Flutter + Dart | 跨平台应用开发 |
| **视频播放** | media_kit | 支持 HarmonyOS |
| **拼音处理** | lpinyin | 自动生成拼音 |
| **文件选择** | file_picker | 用户上传视频 |
| **文件存储** | path_provider | 获取应用文档目录 |
| **配置管理** | JSON (AssetBundle) | 轻量级数据格式 |
| **版本控制** | Git | 代码和配置版本管理 |

## 优化亮点

### 1. 分离关注

- **配置数据**：集中在 `hanzi_config.json`，单一数据源
- **学习状态**：持久化到本地 `characters.json`
- **视频资源**：统一存储在 `/mp4/` 目录

### 2. 灵活的视频来源

支持三种视频来源：
- 项目仓库中的 `/mp4/` 目录（external）
- 应用内置的 `assets/mp4/`（builtin）
- 用户上传的本地视频（userUploaded）

### 3. 易于维护

- 新增汉字只需编辑 `hanzi_config.json`
- 配置更新自动同步（重新构建应用）
- 拼音自动生成，无需手工维护

### 4. 性能优化

- ConfigLoader 缓存配置（避免重复加载）
- AssetBundle 原生支持，加载速度快
- 学习状态只保存差异（基础数据从配置读取）

## 部署流程

### 本地开发

```bash
# 1. 更新配置
vim hanzi_config.json

# 2. 同步配置到应用
cp hanzi_config.json my_app/assets/config/

# 3. 重新构建
cd my_app
flutter clean
flutter pub get
flutter run
```

### 提交到 GitHub

```bash
# 1. 提交配置和视频
git add hanzi_config.json mp4/
git commit -m "feat: add new characters (绿, 树)"

# 2. 更新应用配置
git add my_app/assets/config/hanzi_config.json
git commit -m "chore: sync hanzi config"

# 3. 推送
git push origin main
```

### 构建发布版本

```bash
cd my_app

# 生成分包 APK
flutter build apk --release --split-per-abi

# APK 输出目录
ls build/app/outputs/flutter-apk/

# 可选：生成 AAB（Google Play 发布）
flutter build appbundle --release
```

## 扩展点

### 支持的扩展

1. **更多汉字**：直接编辑 `hanzi_config.json` + 添加视频
2. **多语言**：可扩展配置为 `hanzi_config_zh.json`, `hanzi_config_en.json`
3. **字体样式**：可在配置中添加 `strokeOrder.json` 引用笔画数据
4. **统计功能**：Repository 可保存学习进度统计
5. **云同步**：可集成 Firebase Firestore 同步学习状态

### 不推荐的做法

❌ 硬编码汉字列表到代码中
❌ 视频文件随意命名（拼音命名最佳）
❌ 学习状态存储在配置文件中
❌ 大量内置视频到 APK（应使用外部存储）

---

*文档版本：1.0 | 更新于 2026-03-01*
