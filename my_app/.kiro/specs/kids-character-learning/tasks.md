# 实现计划：儿童汉字学习 App

## 概述

按照三层架构（数据源层 → 服务层 → UI 层）逐步实现，先搭建基础结构和数据层，再实现列表页与搜索，最后实现视频播放页，最终完成整体串联。

## 任务

- [x] 1. 配置项目依赖与资源声明
  - 在 `pubspec.yaml` 中添加 `video_player` 依赖
  - 在 `pubspec.yaml` 的 `flutter.assets` 中声明 `assets/mp4/` 目录
  - _需求：1.2、4.1_

- [x] 2. 实现 CharacterRepository 数据层
  - [x] 2.1 创建 `lib/repositories/character_repository.dart`
    - 定义 `CharacterRepository` 抽象类，包含 `Future<List<String>> loadCharacters()` 方法
    - 实现 `AssetCharacterRepository`，读取 `AssetManifest`，过滤 `assets/mp4/` 下的 `.mp4` 文件并提取汉字名
    - _需求：1.2_
  - [ ]* 2.2 为 `CharacterRepository` 编写单元测试
    - 使用 mock `AssetBundle` 验证正确解析汉字列表
    - 验证空目录时返回空列表
    - _需求：1.2、1.4_

- [x] 3. 实现搜索过滤逻辑
  - [x] 3.1 创建 `lib/utils/filter.dart`，实现 `filter(List<String> characters, String query)` 函数
    - 空查询返回全部，非空查询返回包含查询词的汉字
    - _需求：2.2、2.3_
  - [ ]* 3.2 为 `filter` 函数编写属性测试（`test/utils/filter_test.dart`）
    - **属性 1：过滤结果一致性** — 结果中每个汉字都包含查询词；空查询返回原列表
    - **属性 2：过滤结果为原列表子集** — 结果中每项都存在于原始列表
    - **属性 3：清除搜索恢复全部** — 任意非空查询过滤后再用空串过滤，结果等于原列表
    - 每个属性至少运行 100 次迭代，注释标注 `// Feature: kids-character-learning, Property {编号}: {描述}`
    - _需求：2.2、2.3、2.5_

- [x] 4. 实现汉字列表页
  - [x] 4.1 创建 `lib/widgets/character_card.dart`
    - 实现 `CharacterCard` 无状态 Widget，接收 `character` 和 `onTap` 参数
    - 卡片中央以大号字体显示汉字
    - _需求：1.3_
  - [x] 4.2 创建 `lib/pages/character_list_page.dart`
    - 实现 `CharacterListPage`，调用 `CharacterRepository.loadCharacters()` 获取汉字列表
    - 使用 `GridView` 渲染 `CharacterCard` 网格
    - 列表为空时显示"暂无可学习的汉字"提示
    - _需求：1.1、1.2、1.4_
  - [x] 4.3 在 `CharacterListPage` 中集成搜索栏
    - 页面顶部添加 `TextField` 搜索栏，带清除按钮
    - 输入时调用 `filter` 函数实时过滤卡片列表
    - 搜索无结果时显示"未找到匹配的汉字"提示
    - _需求：2.1、2.2、2.3、2.4、2.5_
  - [ ]* 4.4 为 `CharacterListPage` 编写 Widget 测试
    - 测试空列表时显示提示文字（需求 1.4）
    - 测试搜索无结果时显示提示文字（需求 2.4）
    - 测试点击卡片后导航至 `VideoPlayerPage`（需求 3.1）
    - _需求：1.4、2.4、3.1_

- [x] 5. 检查点 — 确保所有测试通过
  - 确保所有测试通过，如有疑问请向用户确认。

- [x] 6. 实现视频播放页
  - [x] 6.1 创建 `lib/pages/video_player_page.dart`
    - 实现 `VideoPlayerPage`，接收 `character` 字符串参数
    - 页面显示汉字名称和返回按钮
    - 使用 `VideoPlayerController.asset('assets/mp4/$character.mp4')` 加载视频
    - `initState` 中初始化并自动播放，`dispose` 中释放控制器
    - _需求：3.2、3.3、4.1_
  - [x] 6.2 在 `VideoPlayerPage` 中实现播放控制与错误处理
    - 添加播放/暂停切换按钮，点击切换状态
    - 视频播放完毕后停止在最后一帧
    - 视频加载失败时捕获异常，设置 `_hasError = true`，显示"该视频暂不可用"提示
    - 以全宽方式展示视频并保持原始宽高比（使用 `AspectRatio`）
    - _需求：4.2、4.3、4.4、4.5_
  - [ ]* 6.3 为 `VideoPlayerPage` 编写 Widget 测试
    - 使用 mock `VideoPlayerController` 测试自动播放（需求 4.1）
    - 测试视频资源不存在时显示错误提示（需求 4.4）
    - 测试视频播放完毕后停止在最后一帧（需求 4.3）
    - 测试存在返回按钮（需求 3.3）
    - _需求：3.3、4.1、4.3、4.4_
  - [ ]* 6.4 为视频播放页编写属性测试
    - **属性 4：视频播放页显示汉字名称** — 任意汉字字符串，渲染页面后应包含该字符串
    - **属性 5：播放/暂停状态切换** — 任意初始播放状态，点击按钮后状态应翻转
    - 每个属性至少运行 100 次迭代，注释标注 `// Feature: kids-character-learning, Property {编号}: {描述}`
    - _需求：3.2、4.2_

- [x] 7. 改造 main.dart 完成整体串联
  - 修改 `lib/main.dart`，将 `CharacterListPage` 设为首页
  - 注入 `AssetCharacterRepository` 实例
  - 在 `CharacterListPage` 的卡片点击回调中使用 `Navigator.push` 导航至 `VideoPlayerPage`
  - _需求：1.1、3.1_

- [x] 8. 最终检查点 — 确保所有测试通过
  - 确保所有测试通过，如有疑问请向用户确认。

## 备注

- 标有 `*` 的子任务为可选项，可在快速 MVP 阶段跳过
- 每个任务均引用具体需求条款，便于追溯
- 属性测试验证普遍正确性，单元测试验证具体示例和边界情况
- 检查点确保每个阶段的增量验证
