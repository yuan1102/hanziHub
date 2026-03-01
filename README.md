# 汉字Hub - 汉字学习应用

## 项目介绍

汉字Hub 是一个专注于汉字学习的 Flutter 移动应用，旨在帮助用户通过视频解读和交互式学习深入理解汉字的含义、结构和使用方法。

## 项目结构

```
hanziHub/
├── my_app/          # Flutter Android 源代码
├── mp4/             # 汉字解读视频文件库
│   └── 绿.mp4       # 汉字"绿"的解读视频
├── README.md        # 项目说明文档
└── .git/            # Git 版本控制
```

## 核心特性

- **视频解读**：每个汉字都配有详细的解读视频
- **Flutter 跨平台**：基于 Flutter 开发，支持 Android 平台
- **汉字学习**：从字义、字形、字音多维度讲解汉字

## 技术栈

- **前端框架**：Flutter
- **目标平台**：Android
- **视频资源**：MP4 格式

## 快速开始

### 环境要求

- Flutter SDK >= 3.0
- Android SDK
- Dart >= 3.0

### 构建与运行

```bash
cd my_app
flutter pub get
flutter run
```

---

## 配置管理

### 文件结构

```
hanziHub/
├── hanzi_config.json          # 汉字库主配置（维护所有汉字信息）
├── mp4/                       # 外部视频文件存储
│   └── 绿.mp4                 # 汉字视频文件（中文命名）
└── my_app/
    └── assets/
        ├── config/
        │   └── hanzi_config.json    # 配置文件副本（应用打包）
        └── mp4/                     # 内置视频目录（可选）
```

### 添加新汉字

#### 步骤 1：在根目录配置文件中添加条目

编辑 `/hanzi_config.json`，在 `characters` 数组中添加新项：

```json
{
  "name": "树",
  "pinyin": "shù",
  "tone": 4,
  "meaning": "植物，有树干和树叶",
  "videoFile": "树.mp4",
  "videoSource": "external",
  "duration": 45.0,
  "fileSize": "1.9M"
}
```

#### 步骤 2：将视频文件放入 `/mp4/` 目录

```bash
# 在项目根目录执行
cp /path/to/树.mp4 ./mp4/
```

#### 步骤 3：同步到应用资源

```bash
# 将配置文件复制到应用目录
cp hanzi_config.json my_app/assets/config/
```

#### 步骤 4：重新构建应用

```bash
cd my_app
flutter pub get
flutter run
```

### 字段说明

| 字段 | 类型 | 说明 | 例子 |
|------|------|------|------|
| name | String | 汉字 | "绿" |
| pinyin | String | 拼音（小写，可含声调符号） | "lü" |
| tone | Integer? | 声调数字（1-4） | 3 |
| meaning | String | 汉字含义 | "颜色，绿色" |
| videoFile | String | 视频文件名（与 mp4/ 中的文件名一致） | "绿.mp4" |
| videoSource | String | 视频来源类型 | "external" 或 "builtin" |
| duration | Float? | 视频时长（秒） | 43.7 |
| fileSize | String? | 文件大小 | "1.8M" |

### 配置加载器 API

应用中可使用 `ConfigLoader` 访问汉字配置：

```dart
import 'services/config_loader.dart';

// 加载全部汉字配置
List<HanziConfigItem> items = await ConfigLoader.loadConfig();

// 按汉字名查找
HanziConfigItem? item = await ConfigLoader.findByName('绿');

// 按拼音查找
HanziConfigItem? item = await ConfigLoader.findByPinyin('lü');

// 获取配置版本
String version = await ConfigLoader.getConfigVersion();
```

## 项目状态

开发中 🚀

---

*更新于 2026-03-01*
