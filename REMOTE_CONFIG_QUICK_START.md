# 线上配置 - 快速开始

## 核心理念

**零编译更新：修改 GitHub 配置 → 用户自动获取新汉字**

---

## 工作流程

```
修改 GitHub hanzi_config.json
  ↓
用户打开应用
  ↓
自动加载线上配置
  ↓
显示新汉字（无需重装！）
```

---

## 添加新汉字（3 步）

### Step 1: 编辑配置

编辑 `/hanzi_config.json`（项目根目录）

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

### Step 2: 推送到 GitHub

```bash
git add hanzi_config.json
git commit -m "add new character: 树"
git push origin main
```

### Step 3: 用户自动获取

```
用户下次打开应用 → 自动加载最新配置 → 显示新汉字
```

---

## 配置加载优先级

```
线上配置（GitHub CDN）
  ↓ 失败 或 超时
本地缓存（24小时内）
  ↓ 无缓存 或 过期
内置配置（assets）
  ↓ 为空
AssetManifest 扫描
```

---

## 缓存策略

```
首次打开：线上 → 缓存 → 显示
后续 24h：缓存 → 显示（快速）
超过 24h：重新线上 → 缓存 → 显示
无网络：缓存 → 显示
```

---

## 网络适应

| 网络 | 体验 | 结果 |
|------|------|------|
| 快速 | ✅ 最新 | 线上加载 |
| 普通 | ✅ 最新 | 线上加载（稍延迟） |
| 慢速 | ⚠️ 可用 | 本地缓存 |
| 无网 | ⚡ 快速 | 本地缓存 |

---

## 配置格式

### 必填字段

```json
{
  "name": "字",          // 汉字
  "pinyin": "zi",        // 拼音
  "videoFile": "字.mp4", // 文件名
  "videoSource": "remote",    // 来源
  "videoUrl": "https://..."   // 完整 URL
}
```

### 可选字段

```json
{
  "tone": 1,             // 声调
  "meaning": "含义",     // 释义
  "duration": 45.0,      // 时长
  "fileSize": "1.9M"     // 大小
}
```

---

## 线上 URL 格式

```
https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/hanzi_config.json
```

- `yuan1102` → GitHub 用户名
- `hanziHub` → 仓库名
- `@main` → 分支
- `hanzi_config.json` → 配置文件

---

## 代码改动

### ConfigLoader（新增）

```dart
// 加载配置（线上 → 缓存 → 内置）
await ConfigLoader.loadConfig()

// 清除缓存
await ConfigLoader.clearCache()
```

### CharacterRepository（改进）

```dart
// 使用 ConfigLoader 加载
final configItems = await ConfigLoader.loadConfig()
```

---

## 文件位置

```
项目根目录
├── hanzi_config.json           ← 编辑这里
│
GitHub 仓库
└── main 分支
    └── hanzi_config.json       ← 推送这里
```

---

## 常见操作

### 添加新汉字

```bash
# 1. 编辑配置
vim hanzi_config.json

# 2. 推送
git add hanzi_config.json
git push origin main

# 3. 用户自动获取（下次打开时）
```

### 修改已有汉字

```bash
# 1. 编辑配置（修改 URL、含义等）
vim hanzi_config.json

# 2. 推送
git push origin main

# 3. 用户下次打开时自动更新
```

### 删除汉字

```bash
# 1. 从 characters 数组中删除条目
vim hanzi_config.json

# 2. 推送
git push origin main

# 3. 用户下次打开时自动更新
```

---

## 故障排除

### ❌ 新汉字没显示

- [ ] 配置已推送到 GitHub
- [ ] JSON 格式正确
- [ ] 用户有网络
- [ ] 用户重启应用

解决：清除本地缓存后重试

### ❌ 加载很慢

- 网络慢 → 等待或使用 WiFi
- CDN 访问慢 → 稍后重试

### ❌ 无法获取配置

- 检查网络连接
- 检查 URL 是否正确
- 检查仓库是否公开

---

## 更新周期

```
缓存时间：24 小时
超过 24h：下次打开重新获取
清除缓存：立即获取最新
```

---

## 版本管理

### 可选：使用 Git Tag 锁定版本

```bash
# 创建 Tag
git tag v1.0.0
git push origin v1.0.0

# 配置 URL 改为
https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@v1.0.0/hanzi_config.json
```

---

## 现在你可以

✅ 修改 GitHub 配置添加新汉字
✅ 用户下次打开自动获取
✅ 无需重新编译和发布应用
✅ 零编译更新！

---

*版本：1.0 | 更新于 2026-03-01*
