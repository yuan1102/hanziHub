# 添加新汉字操作指南

## 快速流程（3 步）

### 1️⃣ 更新配置文件

编辑 `hanzi_config.json`，在 `characters` 数组中加入新项：

```json
{
  "name": "绿",
  "pinyin": "lü",
  "tone": 3,
  "meaning": "颜色，绿色",
  "videoFile": "绿.mp4",
  "videoSource": "external",
  "duration": 43.7,
  "fileSize": "1.8M"
}
```

**必填字段**：`name`, `pinyin`, `videoFile`, `videoSource`
**可选字段**：`tone`, `meaning`, `duration`, `fileSize`

### 2️⃣ 放置视频文件

将 MP4 视频文件复制到 `/mp4/` 目录：

```bash
cp 新汉字.mp4 /path/to/hanziHub/mp4/
```

**要求**：
- 文件名必须与配置中的 `videoFile` 完全一致（区分大小写）
- 支持中文命名（如 `绿.mp4`、`树.mp4`）
- 格式必须为 MP4

### 3️⃣ 同步并重新构建

```bash
# 将更新的配置复制到应用目录
cp hanzi_config.json my_app/assets/config/

# 进入应用目录并重新构建
cd my_app
flutter pub get
flutter run
```

---

## 详细字段说明

### name（汉字）
- **类型**：String
- **例子**：`"绿"`, `"树"`, `"自"`
- **说明**：单个汉字或多字组合，用于应用中的显示和搜索

### pinyin（拼音）
- **类型**：String
- **例子**：`"lü"`, `"shù"`, `"zì"`
- **说明**：拼音（全小写），可包含声调符号（ā á ǎ à ē é ě è ...）
- **用途**：生成拼音文件名、搜索功能、拼音显示

### tone（声调数字）
- **类型**：Integer（可选）
- **有效值**：1, 2, 3, 4, 5（5 表示轻声）
- **例子**：`1` (一声)、`3` (三声)、`4` (四声)
- **说明**：声调序号，用于拼音显示和教学

### meaning（含义）
- **类型**：String（可选）
- **例子**：`"颜色，绿色"`, `"植物，有树干"`
- **说明**：汉字的简要释义，用于学习辅助

### videoFile（视频文件名）
- **类型**：String
- **例子**：`"绿.mp4"`, `"树.mp4"`
- **要求**：
  - 必须与 `/mp4/` 目录中的文件名完全一致
  - 需包含扩展名 `.mp4`
  - 支持中文文件名

### videoSource（视频来源）
- **类型**：String
- **有效值**：`"external"`, `"builtin"`
- **说明**：
  - `external`：外部存储的视频（/mp4/ 目录）
  - `builtin`：内置于应用资源的视频（assets/mp4/）

### duration（视频时长）
- **类型**：Float（可选）
- **单位**：秒
- **例子**：`43.7`, `120.5`
- **说明**：用于 UI 显示和分析

### fileSize（文件大小）
- **类型**：String（可选）
- **例子**：`"1.8M"`, `"2.3M"`, `"500KB"`
- **说明**：供参考，用于容量规划

---

## 完整示例

### 单个新汉字

```json
{
  "name": "树",
  "pinyin": "shù",
  "tone": 4,
  "meaning": "植物，有树干和树叶",
  "videoFile": "树.mp4",
  "videoSource": "external",
  "duration": 45.2,
  "fileSize": "1.9M"
}
```

### 多条新汉字

编辑后的 `hanzi_config.json` 示例：

```json
{
  "version": "1.0.1",
  "description": "汉字学习应用配置文件",
  "characters": [
    {
      "name": "绿",
      "pinyin": "lü",
      "tone": 3,
      "meaning": "颜色，绿色",
      "videoFile": "绿.mp4",
      "videoSource": "external",
      "duration": 43.7,
      "fileSize": "1.8M"
    },
    {
      "name": "树",
      "pinyin": "shù",
      "tone": 4,
      "meaning": "植物，有树干和树叶",
      "videoFile": "树.mp4",
      "videoSource": "external",
      "duration": 45.2,
      "fileSize": "1.9M"
    },
    {
      "name": "花",
      "pinyin": "huā",
      "tone": 1,
      "meaning": "植物开花的部分",
      "videoFile": "花.mp4",
      "videoSource": "external",
      "duration": 38.5,
      "fileSize": "1.7M"
    }
  ],
  "metadata": {
    "totalCharacters": 3,
    "videoDirectory": "mp4/",
    "lastUpdated": "2026-03-01"
  }
}
```

---

## 批量添加脚本（可选）

如果有很多视频文件需要添加，可使用以下 Python 脚本自动生成配置条目：

```python
import json
import os
from pathlib import Path

# 扫描 mp4 目录
mp4_dir = "./mp4"
config = {
    "version": "1.0.0",
    "description": "汉字学习应用配置文件",
    "characters": [],
    "metadata": {
        "totalCharacters": 0,
        "videoDirectory": "mp4/",
        "lastUpdated": "2026-03-01"
    }
}

for video_file in os.listdir(mp4_dir):
    if video_file.endswith(".mp4"):
        # 提取汉字名（去掉 .mp4）
        char_name = video_file.replace(".mp4", "")

        # 基本配置项
        item = {
            "name": char_name,
            "pinyin": "",  # ⚠️ 需手动填写拼音
            "meaning": "",  # ⚠️ 需手动填写含义
            "videoFile": video_file,
            "videoSource": "external"
        }
        config["characters"].append(item)

# 保存为 JSON
with open("hanzi_config.json", "w", encoding="utf-8") as f:
    json.dump(config, f, ensure_ascii=False, indent=2)

print(f"✅ 生成了 {len(config['characters'])} 个配置项")
print("⚠️  请手动补充每个字的拼音和含义")
```

使用方法：
```bash
python generate_config.py
```

---

## 故障排除

### ❌ 问题：应用无法加载视频

**可能原因**：
1. 视频文件名不匹配（大小写、特殊符号）
2. 视频文件未放入 `/mp4/` 目录
3. 配置文件未同步到应用目录

**解决步骤**：
```bash
# 1. 检查文件是否存在
ls -la mp4/ | grep "你的视频.mp4"

# 2. 检查配置文件中的 videoFile 字段是否正确
grep -A2 "videoFile" hanzi_config.json

# 3. 重新同步配置
cp hanzi_config.json my_app/assets/config/

# 4. 清空应用缓存并重新构建
cd my_app
flutter clean
flutter pub get
flutter run
```

### ❌ 问题：配置文件 JSON 格式错误

**检查方法**：
```bash
# 使用 jq 验证 JSON 格式
jq . hanzi_config.json

# 或使用在线 JSON 验证工具：https://jsonlint.com
```

### ❌ 问题：应用内看不到新添加的汉字

**检查清单**：
- [ ] 配置文件已复制到 `my_app/assets/config/`
- [ ] 视频文件在 `/mp4/` 目录且文件名完全匹配
- [ ] 运行了 `flutter clean && flutter pub get && flutter run`
- [ ] JSON 格式无误（可用 `jq` 检查）

---

## 版本号更新

每次添加汉字后，建议更新 `hanzi_config.json` 中的 `version` 字段：

- `1.0.0` → `1.0.1`（小改）
- `1.0.1` → `1.1.0`（新增多个汉字）
- `1.1.0` → `2.0.0`（大改动）

---

## 常见拼音参考

| 汉字 | 拼音 | 声调 |
|------|------|------|
| 绿 | lü | 3 |
| 树 | shù | 4 |
| 花 | huā | 1 |
| 天 | tiān | 1 |
| 人 | rén | 2 |
| 水 | shuǐ | 3 |
| 火 | huǒ | 3 |
| 土 | tǔ | 3 |
| 山 | shān | 1 |
| 石 | shí | 2 |

---

*最后更新：2026-03-01*
