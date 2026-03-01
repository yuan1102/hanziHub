# 快速参考卡 (Quick Reference)

## 添加汉字的 3 个命令

```bash
# 1️⃣ 编辑配置（添加汉字信息）
nano hanzi_config.json

# 2️⃣ 复制视频文件
cp 你的视频.mp4 mp4/

# 3️⃣ 同步并运行
cp hanzi_config.json my_app/assets/config/ && cd my_app && flutter run
```

---

## 配置文件模板

```json
{
  "name": "字",
  "pinyin": "zi",
  "tone": 4,
  "meaning": "文字、字",
  "videoFile": "字.mp4",
  "videoSource": "external",
  "duration": 45.0,
  "fileSize": "1.9M"
}
```

---

## 常用拼音表

| 汉字 | 拼音 | 汉字 | 拼音 | 汉字 | 拼音 |
|------|------|------|------|------|------|
| 天 | tiān | 人 | rén | 水 | shuǐ |
| 火 | huǒ | 土 | tǔ | 山 | shān |
| 绿 | lü | 树 | shù | 花 | huā |
| 石 | shí | 木 | mù | 大 | dà |

---

## 文件位置

```
项目根目录
├── hanzi_config.json           ← 编辑这里添加汉字
├── mp4/                        ← 放视频在这里
│   └── 绿.mp4
└── my_app/
    └── assets/config/
        └── hanzi_config.json   ← 保持同步
```

---

## 工作流

```
编辑 hanzi_config.json
    ↓
放入视频文件到 mp4/
    ↓
cp hanzi_config.json my_app/assets/config/
    ↓
flutter run
    ↓
✅ 应用显示新汉字
```

---

## 故障排除

### ❌ 视频加载失败
```bash
# 检查文件名是否匹配
ls mp4/ | grep "你的字"
# 检查配置中的 videoFile 字段
grep "videoFile" hanzi_config.json
```

### ❌ JSON 格式错误
```bash
# 验证 JSON 格式
jq . hanzi_config.json
```

### ❌ 应用看不到新汉字
```bash
# 完整重新构建
cd my_app && flutter clean && flutter pub get && flutter run
```

---

## 有用的命令

```bash
# 查看所有视频文件
ls -lh mp4/

# 检查配置文件
cat hanzi_config.json | jq '.characters | length'

# 搜索特定汉字
grep '"name": "绿"' hanzi_config.json

# 验证视频和配置一致
ls mp4/ | sed 's/.mp4$//' > /tmp/videos.txt
jq -r '.characters[].name' hanzi_config.json | sort > /tmp/config.txt
diff /tmp/videos.txt /tmp/config.txt
```

---

## 推送到 GitHub

```bash
git add hanzi_config.json mp4/
git commit -m "feat: add new characters"
git push
```

---

## 更多帮助

- 详细指南：查看 `ADDING_CHARACTERS.md`
- 系统架构：查看 `SYSTEM_ARCHITECTURE.md`
- 完成报告：查看 `OPTIMIZATION_SUMMARY.md`

---

*最后更新：2026-03-01*
