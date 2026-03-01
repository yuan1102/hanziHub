# 线上配置加载指南

**功能版本**：3.0.0
**发布日期**：2026-03-01
**特性**：动态线上配置 + 智能缓存回退

---

## 核心特性

✨ **零编译更新**

- ✅ **直接更新线上配置** — 修改 GitHub 文件即可生效
- ✅ **无需重新编译** — 用户直接获取最新汉字
- ✅ **智能缓存降级** — 网络差时使用本地缓存
- ✅ **自动版本管理** — 24 小时缓存更新周期

---

## 工作流程

### 配置加载优先级

```
1️⃣ 线上配置（GitHub）
    ↓（失败或超时）
2️⃣ 本地缓存（24小时内）
    ↓（无缓存或过期）
3️⃣ 内置配置（assets）
    ↓（内置配置为空）
4️⃣ AssetManifest 扫描
```

### 用户使用流程

```
用户打开应用
    ↓
加载汉字配置
    ↓
├─ 有网络 → 获取线上最新配置 ✅
│              ↓
│          保存到本地缓存（24小时有效）
│              ↓
│          显示汉字列表
│
└─ 无网络 → 使用本地缓存 ⚡
           (如果有的话)
           ↓
         显示汉字列表
```

---

## 配置更新流程

### 添加新汉字（完全无需重编译！）

```
Step 1: 编辑 /hanzi_config.json（项目根目录）
        └─ 在 characters 数组中添加新条目

Step 2: 推送到 GitHub
        git add hanzi_config.json
        git commit -m "add new character"
        git push origin main

Step 3: 用户下次打开应用时
        └─ 自动获取最新配置
        └─ 显示新汉字（无需重新安装！）
```

### 示例：添加"树"字

```json
{
  "name": "树",
  "pinyin": "shù",
  "tone": 4,
  "meaning": "植物，有树干和树叶",
  "videoFile": "树.mp4",
  "videoSource": "remote",
  "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/树.mp4"
}
```

---

## 技术实现

### 配置加载器（ConfigLoader）

```dart
// 1. 尝试从线上加载
final remoteConfig = await _loadRemoteConfig();

// 2. 失败则使用缓存
final cachedConfig = await _loadCachedConfig();

// 3. 缓存也无则使用内置
final builtInConfig = await _loadBuiltInConfig();

// 4. 最后回退到扫描
final scannedConfig = await _scanAssets();
```

### 缓存策略

```dart
// 自动保存到本地
await _saveCachedConfig(response.body);

// 24小时后过期
if (DateTime.now().difference(lastModified) > Duration(hours: 24)) {
  // 缓存已过期，下次将重新获取线上配置
}
```

### 数据仓库（CharacterRepository）

```dart
// 使用 ConfigLoader 加载配置
final configItems = await ConfigLoader.loadConfig();

// 转换为 CharacterEntry
return configItems.map((item) {
  return CharacterEntry(
    name: item.name,
    pinyin: item.pinyin,
    videoSource: item.videoSource == 'remote'
        ? VideoSource.remote
        : VideoSource.builtIn,
    videoUrl: item.videoUrl,
  );
}).toList();
```

---

## 线上配置 URL

### CDN 访问地址

```
https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/hanzi_config.json
```

### 组成部分

- `cdn.jsdelivr.net` — CDN 服务
- `gh/` — GitHub 仓库前缀
- `yuan1102/hanziHub` — 用户/仓库
- `@main` — 分支或 Tag
- `hanzi_config.json` — 文件路径

---

## 缓存管理

### 本地缓存位置

```
应用文档目录/
└── hanzi_config_cache.json
```

### 缓存有效期

```
24 小时内 → 使用缓存（快速）
超过 24h  → 重新获取线上（更新）
```

### 清除缓存

```dart
// 手动清除缓存
await ConfigLoader.clearCache();
```

---

## 网络适应

### 网络很快（100+ Mbps）

```
线上加载：立即成功
缓存保存：快速完成
用户体验：最新配置 ✅
```

### 网络普通（10-50 Mbps）

```
线上加载：1-2 秒完成
缓存保存：成功
用户体验：最新配置（稍有延迟）✅
```

### 网络很慢（5 Mbps）

```
线上加载：超时（10 秒后）
降级方案：使用本地缓存 ⚡
用户体验：稍微延迟，但能使用 ⚠️
```

### 无网络

```
线上加载：失败
降级方案：使用本地缓存 ⚡
用户体验：使用上次缓存的配置 ✓
```

---

## 配置格式

### 完整配置示例

```json
{
  "version": "3.0.0",
  "description": "汉字学习应用 - 线上配置",
  "characters": [
    {
      "name": "绿",
      "pinyin": "lü",
      "tone": 3,
      "meaning": "颜色，绿色",
      "videoFile": "绿.mp4",
      "videoSource": "remote",
      "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/绿.mp4",
      "duration": 43.7,
      "fileSize": "1.8M"
    },
    {
      "name": "树",
      "pinyin": "shù",
      "tone": 4,
      "meaning": "植物，有树干和树叶",
      "videoFile": "树.mp4",
      "videoSource": "remote",
      "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/树.mp4",
      "duration": 45.0,
      "fileSize": "1.9M"
    }
  ],
  "metadata": {
    "totalCharacters": 2,
    "cdnUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main",
    "cacheExpiry": "24h",
    "lastUpdated": "2026-03-01"
  }
}
```

---

## 最佳实践

### ✅ 推荐做法

1. **定期更新配置**
   - 添加新汉字时立即更新
   - 修改视频 URL 时立即推送

2. **保持版本号**
   ```json
   "version": "3.0.1"  // 每次更新递增
   ```

3. **使用 CDN 加速**
   ```
   https://cdn.jsdelivr.net/gh/...  // 自动全球加速
   ```

4. **添加元数据**
   ```json
   "metadata": {
     "totalCharacters": 100,
     "lastUpdated": "2026-03-01"
   }
   ```

### ❌ 避免做法

- 不要直接编辑应用内置配置（应该编辑 GitHub）
- 不要频繁改变版本号（仅版本更新时改）
- 不要删除已发布的汉字（改为标记废弃）

---

## 常见问题

### Q: 修改配置后多久生效？

A:
- 有网络 → 下次打开应用时自动获取（1-2 秒内）
- 无网络 → 使用本地 24 小时内的缓存
- 缓存过期 → 下次有网络时获取最新

### Q: 应用必须有网络吗？

A:
- 首次需要网络获取配置
- 之后有 24 小时缓存，可离线使用
- 缓存过期需要网络更新

### Q: 如何强制更新配置？

A:
- 清除应用数据（会删除缓存）
- 或等待 24 小时缓存过期
- 或在设置中手动清除缓存

### Q: 能否自定义缓存时间？

A: 可以，修改 ConfigLoader 中的：
```dart
static const Duration _cacheExpiry = Duration(hours: 24);
```

### Q: 线上配置 URL 会变吗？

A:
- 分支版本：不变（一直是 main）
- Tag 版本：需要指定（如 @v1.0.0）
- CDN 地址：稳定（GitHub 官方 CDN）

---

## 部署步骤

### 1. 准备线上配置

确保 GitHub 仓库根目录有：
```
hanzi_config.json
```

### 2. 应用配置加载

应用会自动：
```
- 启动时检查网络
- 尝试从 CDN 加载配置
- 失败时使用本地缓存
- 缓存过期后重新获取
```

### 3. 用户无感更新

用户打开应用时：
```
- 自动获取最新配置
- 显示最新汉字列表
- 无需更新应用版本
```

---

## 故障排除

### ❌ 显示不了新汉字

检查清单：
- [ ] `hanzi_config.json` 已推送到 GitHub
- [ ] 文件格式正确（有效的 JSON）
- [ ] URL 格式正确
- [ ] 文件名拼写正确
- [ ] 用户有网络连接

**解决方案**：
```bash
# 验证 JSON 格式
jq . hanzi_config.json

# 清除本地缓存后重试
# 在应用设置中找缓存管理选项
```

### ❌ 配置加载很慢

可能原因：
- 网络速度慢
- CDN 节点远

解决方案：
- 使用高速网络
- 等待缓存保存（后续快速）
- 检查 CDN 可用性

### ❌ 无法获取线上配置

检查：
- [ ] 网络连接是否正常
- [ ] URL 是否正确
- [ ] GitHub 仓库是否公开
- [ ] CDN 是否可访问

---

## 版本演进

| 版本 | 特性 | 获取方式 |
|------|------|----------|
| 1.0 | 无缓存 | 内置配置 |
| 2.0 | 静默缓存 | 内置 + 本地下载 |
| **3.0** | **线上配置** | **线上 + 缓存 + 内置** |

---

## 总结

**v3.0 线上配置是最灵活的方案**：

✨ **零编译更新** — 修改配置即生效
⚡ **智能降级** — 网络差也能用
🎯 **自动优化** — 无需用户操作
📱 **用户友好** — 透明的后台更新

---

*指南版本：1.0 | 更新于 2026-03-01*
