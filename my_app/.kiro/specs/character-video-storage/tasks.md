# 实施计划：汉字视频存储

## 概述

将当前基于纯字符串的汉字管理系统重构为结构化的 `CharacterEntry` 数据模型，引入 JSON 持久化存储、双视频来源支持（内置 + 用户上传），并新增设置页面。实施按数据模型 → 仓库 → 现有页面适配 → 新页面 → 集成的顺序推进。

## 任务

- [x] 1. 创建 CharacterEntry 数据模型和 VideoSource 枚举
  - [x] 1.1 创建 `lib/models/character_entry.dart` 文件
    - 定义 `VideoSource` 枚举（builtIn, userUploaded）
    - 定义 `CharacterEntry` 类，包含 `name`、`pinyin`、`videoSource` 字段
    - 实现 `videoPath` getter：builtIn 返回 `assets/mp4/{pinyin}.mp4`，userUploaded 返回 `{pinyin}.mp4`
    - 实现 `toJson()` 和 `fromJson()` 序列化方法
    - 实现 `==` 运算符和 `hashCode`
    - _需求：1.1, 1.2, 1.3, 1.4_

  - [ ]* 1.2 编写属性测试：视频路径派生
    - **属性 1：视频路径由拼音和来源正确派生**
    - 生成随机拼音和 VideoSource，验证 videoPath 格式正确
    - **验证需求：1.3, 1.4, 3.1**

  - [ ]* 1.3 编写属性测试：序列化往返一致性
    - **属性 2：序列化往返一致性**
    - 生成随机 CharacterEntry 列表，序列化为 JSON 再反序列化，验证等价性
    - **验证需求：2.6, 2.7**

- [x] 2. 重构 CharacterRepository 并实现持久化
  - [x] 2.1 添加 `path_provider` 依赖到 `pubspec.yaml`
    - _需求：2.4_

  - [x] 2.2 重构 `lib/repositories/character_repository.dart`
    - 修改 `CharacterRepository` 抽象类：`loadCharacters()` 返回 `List<CharacterEntry>`，新增 `addCharacter(CharacterEntry)` 和 `deleteCharacter(CharacterEntry)` 方法
    - 实现 `PersistentCharacterRepository`：构造时接收应用文档目录路径
    - 实现 `loadCharacters()`：读取 `characters.json`；若不存在则扫描 AssetManifest 生成初始数据并写入 JSON
    - 实现 `addCharacter()`：验证拼音唯一性，追加条目并写入 JSON
    - 实现 `deleteCharacter()`：仅允许删除 userUploaded 条目，移除条目并写入 JSON，同时删除本地视频文件
    - 实现序列化/反序列化逻辑
    - _需求：2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.4, 6.5_

  - [ ]* 2.3 编写属性测试：添加条目后可加载
    - **属性 3：添加条目后可加载**
    - 生成随机 CharacterEntry，添加到仓库后验证 loadCharacters 包含该条目
    - **验证需求：2.2**

  - [ ]* 2.4 编写属性测试：删除条目后不可加载
    - **属性 4：删除条目后不可加载**
    - 从已有 userUploaded 条目中随机选择一个删除，验证 loadCharacters 不再包含
    - **验证需求：2.3**

  - [ ]* 2.5 编写属性测试：拼音唯一性约束
    - **属性 5：拼音唯一性约束**
    - 尝试添加拼音已存在的条目时应失败
    - **验证需求：3.4, 5.6**

  - [ ]* 2.6 编写属性测试：内置条目不可删除
    - **属性 7：内置条目不可删除**
    - 生成随机 builtIn 条目，尝试删除后验证列表不变
    - **验证需求：6.5**

- [x] 3. 检查点 — 确保数据层正确
  - 确保所有测试通过，如有疑问请询问用户。

- [x] 4. 适配现有页面以使用 CharacterEntry
  - [x] 4.1 修改 `lib/utils/filter.dart`
    - 将 `filter` 函数签名从 `List<String>` 改为 `List<CharacterEntry>`
    - 搜索同时匹配汉字名称和拼音
    - _需求：1.1_

  - [x] 4.2 修改 `lib/widgets/character_card.dart`
    - 将 `character` 参数类型从 `String` 改为 `CharacterEntry`
    - 显示 `entry.name`
    - _需求：1.1_

  - [x] 4.3 修改 `lib/pages/video_player_page.dart`
    - 将参数从 `String character` 改为 `CharacterEntry entry`
    - 根据 `videoSource` 选择 `VideoPlayerController.asset()` 或 `VideoPlayerController.file()`
    - userUploaded 时使用 `path_provider` 获取文档目录拼接完整路径
    - 保留错误处理：显示"该视频暂不可用"
    - _需求：3.2, 3.3, 4.1, 4.2, 4.3, 4.4_

  - [x] 4.4 修改 `lib/pages/character_list_page.dart`
    - 将 `_allCharacters` 类型从 `List<String>` 改为 `List<CharacterEntry>`
    - 更新 `_filtered` getter 和相关引用
    - 传递 `CharacterEntry` 给 `CharacterCard` 和 `VideoPlayerPage`
    - _需求：1.1_

- [x] 5. 检查点 — 确保现有功能适配完成
  - 确保所有测试通过，如有疑问请询问用户。

- [x] 6. 实现设置页面
  - [x] 6.1 添加 `file_picker` 依赖到 `pubspec.yaml`
    - _需求：5.3_

  - [x] 6.2 创建 `lib/pages/settings_page.dart`
    - 显示所有 CharacterEntry 列表，标注来源类型（内置/用户上传）
    - 提供"添加汉字"按钮，弹出表单对话框（输入汉字名称、拼音）
    - 使用 `file_picker` 选择 mp4 文件
    - 验证文件格式（仅 mp4）和拼音唯一性
    - 将选中文件复制到应用文档目录，以 `{pinyin}.mp4` 命名
    - 创建 userUploaded 类型的 CharacterEntry 并保存
    - 支持滑动删除 userUploaded 条目（含确认对话框），同时删除本地视频文件
    - 禁止删除 builtIn 条目
    - _需求：5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 6.1, 6.2, 6.3, 6.4, 6.5_

  - [ ]* 6.3 编写属性测试：文件格式验证
    - **属性 6：文件格式验证**
    - 生成随机文件路径（含各种扩展名），验证非 .mp4 扩展名被拒绝
    - **验证需求：5.7**

- [x] 7. 导航集成与入口连接
  - [x] 7.1 修改 `lib/pages/character_list_page.dart` AppBar
    - 添加设置图标按钮
    - 点击后导航到 SettingsPage
    - 从 SettingsPage 返回时调用 `_loadCharacters()` 刷新列表
    - _需求：7.1, 7.2, 7.3_

  - [x] 7.2 修改 `lib/main.dart`
    - 使用 `path_provider` 获取应用文档目录
    - 创建 `PersistentCharacterRepository` 替代 `AssetCharacterRepository`
    - _需求：2.4_

- [x] 8. 最终检查点 — 确保所有功能集成完成
  - 确保所有测试通过，如有疑问请询问用户。

## 备注

- 标记 `*` 的任务为可选任务，可跳过以加快 MVP 进度
- 每个任务引用了具体的需求编号以确保可追溯性
- 属性测试使用 `glados` 库，需在 `dev_dependencies` 中添加
- 检查点用于增量验证，确保每个阶段的正确性
