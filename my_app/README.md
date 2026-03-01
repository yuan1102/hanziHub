# 汉字学习 App

Flutter 儿童识字学习应用，支持汉字视频播放、学习状态管理、用户自定义上传。

---

## 技术栈

- **Flutter** + Dart
- **media_kit** — 视频播放（替代 video_player，兼容华为 HarmonyOS）
- **lpinyin** — 汉字转拼音（自动生成带声调拼音）
- **file_picker** — 用户上传视频文件
- **path_provider** — 本地文件存储

---

## 项目结构

```
lib/
├── main.dart                          # 入口，MediaKit 初始化
├── models/
│   └── character_entry.dart           # 数据模型（LearnStatus 三态）
├── repositories/
│   └── character_repository.dart      # 数据持久化，AssetManifest 扫描
├── pages/
│   ├── character_list_page.dart       # 首页：三 tab（未学习/已学习/已掌握）
│   ├── video_player_page.dart         # 视频播放页 + 全屏模式
│   └── settings_page.dart             # 设置页：添加/删除汉字条目
├── widgets/
│   ├── character_card.dart            # 汉字卡片（按状态变色）
│   └── video_controls_overlay.dart    # 自定义视频控件
└── utils/
    └── filter.dart                    # 搜索过滤

assets/
└── mp4/                               # 内置汉字视频（中文命名，如 天.mp4）
```

---

## 核心功能

### 学习状态三态管理

| 状态 | 卡片颜色 | Tab |
|------|----------|-----|
| 未学习 (unlearned) | 淡黄色 `#FFF9C4` | 未学习 |
| 已学习 (learned) | 淡绿色 `#C8E6C9` | 已学习 |
| 已掌握 (mastered) | 淡蓝色 `#BBDEFB` | 已掌握 |

- 长按卡片循环切换：未学习 → 已学习 → 已掌握 → 未学习
- 底部 TabBar 显示各状态数量

### 视频播放

- 基于 media_kit（libmpv），自带软件解码，兼容华为 HarmonyOS 设备
- 自定义控件覆盖层（进度条、播放/暂停、全屏）
- 全屏模式：横屏 + 沉浸式 UI

### 汉字管理

- 内置视频通过 AssetManifest 自动扫描，无需手动维护列表
- 拼音由 lpinyin 自动生成（支持声调：ā á ǎ à）
- 设置页支持添加/删除用户自定义汉字视频
- 学习状态持久化到 `characters.json`，支持从旧版 `learned: bool` 自动迁移

---

## 打包

### 使用构建脚本（推荐）

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

脚本会自动按 ABI 分包，生成 3 个独立 APK：

| 文件 | 架构 | 适用设备 |
|------|------|----------|
| `汉字学习-arm64-v8a.apk` | 64 位 ARM | **华为平板**、主流手机 |
| `汉字学习-armeabi-v7a.apk` | 32 位 ARM | 老旧设备 |
| `汉字学习-x86_64.apk` | x86_64 | 模拟器 |

分包后每个 APK 比完整包小约 15-20MB（省掉其他架构的 media_kit 原生库）。

### 手动打包

```bash
flutter build apk --release --split-per-abi
```

### 构建配置

`app_config.json`：

```json
{
  "APP_NAME": "汉字学习",
  "APP_ICON": "assets/icon/app_icon.png",
  "APK_NAME": "汉字学习"
}
```

---

## 添加新汉字视频

### 内置视频

将 MP4 文件放入 `assets/mp4/` 目录，以汉字命名（如 `天.mp4`），重新打包即可自动识别。

### 用户上传

在 App 设置页点击 "+" 按钮，输入汉字后选择本地 MP4 文件。
