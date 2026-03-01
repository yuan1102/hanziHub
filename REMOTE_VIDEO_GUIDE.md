# 远程视频加载指南

## 概述

汉字Hub 现在支持从 **GitHub CDN（jsDelivr）** 加载视频，无需在应用内打包视频文件。

### 优势

✅ **应用包体积小** — 无需打包视频，APK 更小
✅ **易于更新** — 视频更新无需重新编译
✅ **带宽高效** — CDN 加速，加载速度快
✅ **版本管理** — 通过 GitHub Tag 管理版本

---

## 快速配置

### 1️⃣ 在 hanzi_config.json 中添加远程视频

```json
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
```

### 2️⃣ 确保视频在 GitHub 仓库中

```
hanziHub/
├── mp4/
│   ├── 绿.mp4
│   └── 树.mp4
└── ...
```

### 3️⃣ 同步配置到应用

```bash
cp hanzi_config.json my_app/assets/config/
cd my_app && flutter run
```

---

## CDN URL 格式

### jsDelivr 标准格式

```
https://cdn.jsdelivr.net/gh/[用户名]/[仓库名]@[分支或Tag]/[文件路径]
```

### 对于 hanziHub 项目

```
https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/绿.mp4
```

**说明**：
- `yuan1102` — GitHub 用户名
- `hanziHub` — 仓库名
- `main` — 分支名（可用 Tag 如 v1.0.0）
- `mp4/绿.mp4` — 文件路径

---

## 配置字段详解

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `name` | String | ✅ | 汉字 |
| `pinyin` | String | ✅ | 拼音 |
| `tone` | Integer | ❌ | 声调（1-4） |
| `meaning` | String | ❌ | 含义 |
| `videoFile` | String | ❌ | 本地文件名（可选） |
| `videoSource` | String | ✅ | 视频来源：`remote`, `builtin`, `external` |
| `videoUrl` | String | ✅*  | 远程 URL（当 videoSource=remote 时必需） |
| `duration` | Float | ❌ | 视频时长（秒） |
| `fileSize` | String | ❌ | 文件大小 |

*`videoUrl` 当 `videoSource` 为 `remote` 时必需

---

## 视频来源类型

### 1. remote（远程 CDN）✨ 推荐

```json
{
  "videoSource": "remote",
  "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/绿.mp4"
}
```

**优点**：
- 无需在应用打包视频
- 应用包体积小
- 更新无需重新编译

**用途**：生产环境推荐使用

### 2. builtin（内置资源）

```json
{
  "videoSource": "builtin",
  "videoFile": "绿.mp4"
}
```

**要求**：视频必须在 `assets/mp4/` 中

**优点**：
- 加载速度快
- 离线可用

**缺点**：
- APK 包体积大
- 更新需重新编译

### 3. external（本地文件）

```json
{
  "videoSource": "external",
  "videoFile": "绿.mp4"
}
```

**要求**：视频必须在应用文档目录

**用途**：用户上传或动态下载的视频

---

## 完整示例

### 最小配置（仅远程）

```json
{
  "version": "1.1.0",
  "characters": [
    {
      "name": "绿",
      "pinyin": "lü",
      "videoSource": "remote",
      "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/绿.mp4"
    }
  ]
}
```

### 完整配置（包含元数据）

```json
{
  "version": "1.1.0",
  "description": "汉字学习应用配置",
  "characters": [
    {
      "name": "绿",
      "pinyin": "lü",
      "tone": 3,
      "meaning": "颜色，绿色",
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
      "videoSource": "remote",
      "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/树.mp4",
      "duration": 45.0,
      "fileSize": "1.9M"
    }
  ],
  "metadata": {
    "totalCharacters": 2,
    "cdnUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main",
    "lastUpdated": "2026-03-01"
  }
}
```

---

## 添加新汉字（远程视频）

### 步骤 1：确保视频在 GitHub

```bash
# 在项目根目录
git add mp4/新汉字.mp4
git commit -m "add video for 新汉字"
git push origin main
```

### 步骤 2：编辑配置文件

编辑 `hanzi_config.json`，在 `characters` 数组中添加：

```json
{
  "name": "新汉字",
  "pinyin": "pinyin",
  "meaning": "含义说明",
  "videoSource": "remote",
  "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/新汉字.mp4"
}
```

### 步骤 3：同步并运行

```bash
cp hanzi_config.json my_app/assets/config/
cd my_app && flutter run
```

---

## CDN 缓存说明

### 缓存时间

jsDelivr 默认缓存 CDN 节点**30 天**。

### 强制刷新

如果需要立即更新（不等缓存过期）：

```
原 URL：
https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/绿.mp4

强制刷新 URL：
https://purge.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/绿.mp4
```

访问强制刷新 URL 会清除 CDN 缓存。

### 使用 Git Tag（推荐）

为稳定版本创建 Tag，使用 Tag 而非 `main` 分支：

```json
{
  "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@v1.0.0/mp4/绿.mp4"
}
```

**优势**：
- 版本固定，不受 main 分支变化影响
- 自动使用最新缓存，性能更好

---

## 生成 URL 的便利脚本

### Python 脚本

```python
import os
from pathlib import Path

CDN_URL = "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4"
MP4_DIR = "./mp4"

# 扫描所有 mp4 文件
for video_file in os.listdir(MP4_DIR):
    if video_file.endswith(".mp4"):
        char_name = video_file.replace(".mp4", "")
        url = f"{CDN_URL}/{video_file}"
        print(f'{{"name": "{char_name}", "videoSource": "remote", "videoUrl": "{url}"}}')
```

使用方法：
```bash
python generate_urls.py >> hanzi_config.json
```

### Bash 脚本

```bash
#!/bin/bash
CDN_URL="https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4"

for video in mp4/*.mp4; do
    char=$(basename "$video" .mp4)
    echo "\"$char\": \"$CDN_URL/$char.mp4\","
done
```

---

## 故障排除

### ❌ 视频加载失败

检查清单：
- [ ] URL 是否正确拼写
- [ ] 视频文件是否在 GitHub 仓库中
- [ ] GitHub 仓库是否为公开
- [ ] 分支或 Tag 名称是否正确

**调试方法**：
```bash
# 在浏览器中直接访问 URL，看是否能下载
curl -I "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/绿.mp4"
```

### ❌ 视频不能立即更新

这是 CDN 缓存问题。可以：
1. 等待 30 天缓存过期
2. 使用强制刷新 URL
3. 在配置中改用新的 URL（添加版本号等）

### ❌ 应用启动时卡顿

可能是网络加载缓慢。可以：
1. 确保网络连接正常
2. 使用代理加速（中国用户）
3. 考虑配合本地缓存

---

## 最佳实践

### ✅ 推荐做法

1. **使用 Git Tag 版本化**
   ```json
   "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@v1.0.0/mp4/绿.mp4"
   ```

2. **在 metadata 中声明 CDN**
   ```json
   "metadata": {
     "cdnUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main"
   }
   ```

3. **保持配置文件更新**
   ```bash
   cp hanzi_config.json my_app/assets/config/
   git add my_app/assets/config/hanzi_config.json
   git commit -m "sync config"
   ```

### ❌ 避免做法

- 在不同的 CDN 来源混用（可能导致管理混乱）
- 使用生成性的 URL（容易失效）
- 删除已发布的视频文件（会破坏已发布的应用）

---

## 常见配置模板

### 所有视频都在远程

```json
{
  "version": "1.1.0",
  "characters": [
    {
      "name": "字1",
      "pinyin": "zi1",
      "videoSource": "remote",
      "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/字1.mp4"
    },
    {
      "name": "字2",
      "pinyin": "zi2",
      "videoSource": "remote",
      "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/字2.mp4"
    }
  ]
}
```

### 混合本地和远程

```json
{
  "version": "1.1.0",
  "characters": [
    {
      "name": "字1",
      "pinyin": "zi1",
      "videoSource": "builtin",
      "videoFile": "字1.mp4"
    },
    {
      "name": "字2",
      "pinyin": "zi2",
      "videoSource": "remote",
      "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/字2.mp4"
    }
  ]
}
```

---

## 性能对比

| 视频来源 | 包体积 | 加载速度 | 离线可用 | 更新难度 |
|---------|--------|----------|----------|---------|
| **remote（CDN）** | 🟢 最小 | 🟡 中等 | 🔴 否 | 🟢 易 |
| **builtin（内置）** | 🔴 大 | 🟢 快 | 🟢 是 | 🔴 难 |
| **external（本地）** | 🟡 中等 | 🟡 中等 | 🟡 可选 | 🟡 中等 |

---

*指南版本：1.0 | 更新于 2026-03-01*
