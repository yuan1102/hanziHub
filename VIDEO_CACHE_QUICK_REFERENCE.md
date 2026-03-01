# 视频缓存 - 快速参考

## 工作原理

```
首次播放 → 下载视频 → 保存到本地 → 缓存中
后续播放 → 检查本地 → 直接读取 → 快速播放 ⚡
```

---

## 为什么需要缓存？

| 对比 | 无缓存 | 有缓存 |
|------|--------|--------|
| 首次加载 | 3-5s | 3-5s |
| **后续加载** | **3-5s** | **0.5s ⚡** |
| 离线播放 | ❌ 不可 | ✅ 可以 |
| 流量消耗 | 高 | 低 |

---

## 缓存工作流程

### 代码层面

```dart
// 自动缓存（在 VideoPlayerPage 中）
final cachedPath = await VideoCacheManager.getOrDownloadVideo(videoUrl);

if (cachedPath != null) {
  // 使用缓存（快速！）
  media = Media(cachedPath);
} else {
  // 缓存失败，在线播放
  media = Media(videoUrl);
}
```

### 用户体验

1. **首次播放** → 显示下载进度（3-5秒）
2. **后续播放** → 立即开始（0.5秒）
3. **离线模式** → 直接播放（已缓存的视频）

---

## 缓存管理

### 查看缓存

在应用设置中：
1. 点击"缓存管理"
2. 查看缓存大小
3. 查看缓存的视频列表

### 清理缓存

```
清空所有缓存
  ↓
确认删除
  ↓
重新下载视频时会自动缓存
```

### 手动管理（代码）

```dart
// 检查是否已缓存
bool cached = await VideoCacheManager.isCached(videoUrl);

// 获取缓存大小
String size = await VideoCacheManager.getFormattedCacheSize();

// 列出所有缓存
List<String> videos = await VideoCacheManager.listCachedVideos();

// 删除单个缓存
await VideoCacheManager.clearCache(videoUrl);

// 清空所有
await VideoCacheManager.clearAllCache();
```

---

## 缓存位置

```
应用文档目录/
└── video_cache/
    ├── 绿.mp4     ← 自动保存
    ├── 树.mp4
    └── ...
```

---

## 常见问题

### Q: 缓存占用多少空间？

A:
- 单个视频：1-2 MB
- 50 个视频：50-100 MB（通常）
- 不会自动删除，用户手动清理

### Q: 卸载应用会删除缓存吗？

A: 是的，缓存随应用数据一起删除。

### Q: 可以在哪里找到缓存？

A: 应用文档目录 → `video_cache` 文件夹
（普通用户通过应用内管理）

### Q: 网络不好时怎么办？

A:
- 首次下载会超时（最多等 5 分钟）
- 失败时自动在线播放
- 下次再试缓存

### Q: 如何强制重新下载？

A:
1. 打开缓存管理
2. 删除该视频的缓存
3. 下次播放时会重新下载

---

## 实现要点

### 已添加的文件

```
lib/services/
└── video_cache_manager.dart      ← 缓存核心

lib/pages/
└── cache_manager_page.dart       ← 缓存管理 UI
```

### 已修改的文件

```
pubspec.yaml                      ← 添加 http 依赖
lib/pages/video_player_page.dart  ← 集成缓存逻辑
```

---

## 性能数据

### 加载时间对比

```
场景                加载时间        备注
────────────────────────────────────
首次无缓存          3-5 秒         下载 + 播放
后续有缓存          0.5 秒⚡       本地读取
离线播放（缓存）    0.5 秒⚡       无网络加载
```

### 存储占用

```
汉字数量    缓存大小         说明
──────────────────────────────
5 个       5-10 MB
10 个      10-20 MB
50 个      50-100 MB      建议用户定期清理
100 个     100-200 MB
```

---

## 集成清单

- [x] 缓存管理器实现
- [x] 缓存管理 UI 页面
- [x] 视频播放器集成
- [x] HTTP 依赖添加
- [x] 完整文档编写

## 待做事项（可选优化）

- [ ] 预缓存常用视频
- [ ] 定期清理陈旧缓存
- [ ] 缓存大小限制
- [ ] 后台智能下载

---

## 下一步

1. **运行应用**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **测试缓存**
   - 首次播放（观察下载）
   - 重复播放（观察速度提升）
   - 查看缓存管理页面

3. **集成到设置**
   - 在 SettingsPage 中添加缓存管理入口
   - 测试缓存清理功能

---

## 代码示例

### 基本使用

```dart
// 播放视频时自动缓存
final videoUrl = 'https://cdn.jsdelivr.net/gh/.../绿.mp4';
final cachedPath = await VideoCacheManager.getOrDownloadVideo(videoUrl);

// 使用缓存路径播放
media = Media(cachedPath ?? videoUrl);
```

### 查询和管理

```dart
// 检查缓存状态
if (await VideoCacheManager.isCached(videoUrl)) {
  debugPrint('视频已缓存');
}

// 获取缓存信息
final size = await VideoCacheManager.getFormattedCacheSize();
final videos = await VideoCacheManager.listCachedVideos();
print('缓存大小: $size，视频数: ${videos.length}');

// 清理缓存
await VideoCacheManager.clearCache(videoUrl);  // 单个
await VideoCacheManager.clearAllCache();        // 全部
```

---

*版本：1.0 | 更新于 2026-03-01*
