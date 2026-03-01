# 远程视频 - 快速开始

## 3 步添加远程视频

### 1️⃣ 编辑配置

在 `hanzi_config.json` 添加新条目：

```json
{
  "name": "树",
  "pinyin": "shù",
  "videoSource": "remote",
  "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/树.mp4"
}
```

### 2️⃣ 推送到 GitHub

```bash
# 在项目根目录，确保视频文件在仓库中
git add mp4/树.mp4
git commit -m "add video for 树"
git push origin main
```

### 3️⃣ 运行应用

```bash
# 同步配置
cp hanzi_config.json my_app/assets/config/

# 重新运行
cd my_app && flutter run
```

---

## CDN URL 生成

### 格式

```
https://cdn.jsdelivr.net/gh/[用户名]/[仓库]/@[分支]/mp4/[文件名]
```

### 对于 hanziHub

```
https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/绿.mp4
```

---

## 配置模板

### 最小配置

```json
{
  "name": "字",
  "pinyin": "zi",
  "videoSource": "remote",
  "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/字.mp4"
}
```

### 完整配置

```json
{
  "name": "字",
  "pinyin": "zi",
  "tone": 1,
  "meaning": "文字",
  "videoSource": "remote",
  "videoUrl": "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/字.mp4",
  "duration": 45.0,
  "fileSize": "1.9M"
}
```

---

## 视频来源对比

| 类型 | videoSource | videoUrl | 说明 |
|------|-------------|----------|------|
| CDN（推荐） | `remote` | ✅ 必需 | 远程加载 |
| 内置 | `builtin` | ❌ 无需 | 打包在应用 |
| 本地 | `external` | ❌ 无需 | 应用文件夹 |

---

## 验证配置

```bash
# 检查 JSON 格式
jq . hanzi_config.json

# 测试 CDN URL（应该能下载）
curl -I "https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/绿.mp4"
```

---

## 常见错误

### ❌ "暂无可学习的汉字"

**原因**：配置文件格式错误或未加载

**解决**：
```bash
# 1. 检查配置格式
jq . hanzi_config.json

# 2. 确保已同步到应用
cp hanzi_config.json my_app/assets/config/

# 3. 完整重新构建
cd my_app && flutter clean && flutter pub get && flutter run
```

### ❌ 视频不能加载

**原因**：URL 错误或网络问题

**解决**：
```bash
# 在浏览器或 curl 中测试 URL
curl -I "你的URL"

# 确保仓库是公开的
# 确保分支名正确（main 或 master）
```

---

## 批量配置脚本

### 自动生成 URL

```bash
#!/bin/bash
# 扫描所有 mp4 文件并生成配置

echo "["
for video in mp4/*.mp4; do
    char=$(basename "$video" .mp4)
    url="https://cdn.jsdelivr.net/gh/yuan1102/hanziHub@main/mp4/$char.mp4"
    echo "  {"
    echo "    \"name\": \"$char\","
    echo "    \"pinyin\": \"待填写\","
    echo "    \"videoSource\": \"remote\","
    echo "    \"videoUrl\": \"$url\""
    echo "  },"
done
echo "]"
```

使用：
```bash
bash generate_config.sh > output.json
```

---

## 下一步

- 详细指南：`REMOTE_VIDEO_GUIDE.md`
- 系统架构：`SYSTEM_ARCHITECTURE.md`
- 添加汉字：`ADDING_CHARACTERS.md`

---

*最后更新：2026-03-01*
