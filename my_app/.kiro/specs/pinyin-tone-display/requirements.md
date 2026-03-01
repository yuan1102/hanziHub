# 需求文档

## 介绍

本功能为儿童汉字学习应用添加带声调的拼音显示能力。当前应用使用简化拼音（如 'lv'）作为文件名和内部标识符，但在用户界面上应该显示标准的带声调拼音（如 'lǜ'）。此功能将更新字符卡片以同时显示汉字和正确的带声调拼音，提升学习体验的准确性和教育价值。

## 术语表

- **Character_Card**: 显示单个汉字的 UI 组件
- **Pinyin_Mapper**: 将简化拼音（文件名格式）转换为带声调拼音的组件
- **Character_Entry**: 表示汉字条目的数据模型，包含汉字、拼音和视频来源
- **Character_Repository**: 管理汉字条目数据的持久化和加载
- **Simplified_Pinyin**: 不带声调的拼音表示，用于文件名（如 'lv', 'nv'）
- **Toned_Pinyin**: 带声调标记的标准拼音（如 'lǜ', 'nǚ'）

## 需求

### 需求 1: 拼音映射数据

**用户故事:** 作为开发者，我需要一个从简化拼音到带声调拼音的映射表，以便在界面上显示正确的拼音。

#### 验收标准

1. THE Pinyin_Mapper SHALL 提供从 Simplified_Pinyin 到 Toned_Pinyin 的映射
2. THE Pinyin_Mapper SHALL 支持所有现有 chargeMap 中的拼音键值
3. WHEN Simplified_Pinyin 在映射表中不存在时，THE Pinyin_Mapper SHALL 返回原始的 Simplified_Pinyin
4. THE Pinyin_Mapper SHALL 正确处理多音字的不同拼音（如 'de' 和 'de1'）

### 需求 2: 字符条目数据模型更新

**用户故事:** 作为开发者，我需要 Character_Entry 模型能够存储和提供带声调的拼音，以便在 UI 中显示。

#### 验收标准

1. THE Character_Entry SHALL 提供获取 Toned_Pinyin 的方法
2. THE Character_Entry SHALL 保持现有的 pinyin 字段用于文件路径和内部标识
3. WHEN Character_Entry 被创建时，THE Character_Entry SHALL 自动关联对应的 Toned_Pinyin
4. THE Character_Entry SHALL 保持向后兼容性，不破坏现有的序列化和反序列化逻辑

### 需求 3: 字符卡片显示

**用户故事:** 作为儿童用户，我想在字符卡片上同时看到汉字和带声调的拼音，以便学习正确的发音。

#### 验收标准

1. THE Character_Card SHALL 在卡片上显示汉字
2. THE Character_Card SHALL 在汉字下方或上方显示 Toned_Pinyin
3. THE Character_Card SHALL 使用清晰可读的字体大小显示拼音
4. THE Character_Card SHALL 保持视觉层次，汉字应比拼音更突出
5. THE Character_Card SHALL 在不同屏幕尺寸上保持良好的布局

### 需求 4: 仓库初始化兼容性

**用户故事:** 作为开发者，我需要确保现有用户的数据能够平滑迁移到新的拼音显示系统，以便不影响用户体验。

#### 验收标准

1. WHEN Character_Repository 加载现有的 characters.json 文件时，THE Character_Repository SHALL 正确解析所有条目
2. WHEN Character_Repository 扫描内置视频时，THE Character_Repository SHALL 为每个条目关联正确的 Toned_Pinyin
3. THE Character_Repository SHALL 保持现有的 chargeMap 用于汉字映射
4. THE Character_Repository SHALL 不修改文件系统中的视频文件名或路径结构

### 需求 5: 用户上传字符支持

**用户故事:** 作为用户，当我上传自定义汉字视频时，我希望能够输入带声调的拼音，以便正确显示。

#### 验收标准

1. WHEN 用户添加新的 Character_Entry 时，THE 应用 SHALL 允许用户输入 Toned_Pinyin
2. WHEN 用户输入 Toned_Pinyin 时，THE 应用 SHALL 自动生成对应的 Simplified_Pinyin 用于文件命名
3. IF 用户输入的拼音无法转换为有效的 Simplified_Pinyin，THEN THE 应用 SHALL 显示错误提示
4. THE 应用 SHALL 在字符列表中显示用户输入的 Toned_Pinyin

### 需求 6: 拼音转换准确性

**用户故事:** 作为开发者，我需要确保拼音转换的准确性，以便提供正确的教育内容。

#### 验收标准

1. THE Pinyin_Mapper SHALL 正确处理所有四个声调（阴平、阳平、上声、去声）
2. THE Pinyin_Mapper SHALL 正确处理轻声（如 'de'）
3. THE Pinyin_Mapper SHALL 正确处理 ü 的表示（如 'lv' -> 'lǜ', 'nv' -> 'nǚ'）
4. FOR ALL 现有的 chargeMap 条目，转换后的 Toned_Pinyin SHALL 符合汉语拼音标准
