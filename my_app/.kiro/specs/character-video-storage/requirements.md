# 需求文档：汉字视频存储

## 简介

本功能为汉字学习应用引入持久化的汉字存储仓库和视频管理系统。当前应用直接从 `assets/mp4/` 目录加载视频，使用中文字符作为文件名，导致编码问题。本功能将：
1. 建立结构化的汉字数据模型（包含汉字名称、拼音、视频来源等信息）
2. 使用拼音作为视频文件名，解决中文文件名编码问题
3. 支持内置视频（预打包）和用户上传视频两种来源
4. 新增设置页面，允许用户上传和管理视频

## 术语表

- **Character_Repository**：汉字存储仓库，负责汉字条目的持久化存储与读取
- **Character_Entry**：汉字条目数据模型，包含汉字名称、拼音、视频来源等字段
- **Video_Source**：视频来源类型，分为内置（built-in）和用户上传（user-uploaded）两种
- **Built_In_Video**：预打包在 `assets/mp4/` 目录中的内置视频，使用拼音命名
- **User_Uploaded_Video**：用户通过设置页面上传并存储在应用本地存储中的视频
- **Settings_Page**：设置页面，提供视频上传和汉字管理功能
- **Video_Player_Page**：视频播放页面，根据视频来源加载并播放对应视频
- **Pinyin_Filename**：使用拼音作为视频文件名的命名方式（如 `miao.mp4` 代替 `苗.mp4`）
- **Local_Storage**：应用本地文件存储目录，用于存放用户上传的视频文件

## 需求

### 需求 1：汉字数据模型

**用户故事：** 作为开发者，我希望有一个结构化的汉字数据模型，以便系统能够统一管理汉字名称、拼音和视频来源信息。

#### 验收标准

1. THE Character_Entry SHALL 包含以下字段：汉字名称（String）、拼音（String）、视频来源类型（Video_Source 枚举）
2. THE Video_Source SHALL 定义两种枚举值：builtIn（内置）和 userUploaded（用户上传）
3. WHEN Video_Source 为 builtIn 时，THE Character_Entry SHALL 使用拼音构建 `assets/mp4/{pinyin}.mp4` 作为视频路径
4. WHEN Video_Source 为 userUploaded 时，THE Character_Entry SHALL 使用拼音构建 Local_Storage 中的 `{pinyin}.mp4` 作为视频路径

### 需求 2：汉字持久化存储仓库

**用户故事：** 作为用户，我希望应用能够持久化保存汉字列表，以便每次打开应用时都能看到之前添加的汉字。

#### 验收标准

1. THE Character_Repository SHALL 提供加载全部汉字条目的功能，返回 Character_Entry 列表
2. THE Character_Repository SHALL 提供添加新汉字条目的功能
3. THE Character_Repository SHALL 提供删除指定汉字条目的功能
4. THE Character_Repository SHALL 将汉字数据持久化存储到本地（如 JSON 文件或 SharedPreferences）
5. WHEN 应用首次启动且无持久化数据时，THE Character_Repository SHALL 从 `assets/mp4/` 目录扫描内置视频并自动生成初始汉字条目列表
6. THE Character_Repository SHALL 对汉字条目列表进行序列化和反序列化操作
7. FOR ALL 有效的 Character_Entry 列表，序列化后再反序列化 SHALL 产生等价的对象（往返一致性）

### 需求 3：拼音文件名映射

**用户故事：** 作为开发者，我希望使用拼音作为视频文件名，以便避免中文字符在文件系统和 AssetManifest 中的编码问题。

#### 验收标准

1. THE Character_Repository SHALL 使用 Pinyin_Filename 格式存储和引用所有视频文件
2. WHEN 加载内置视频时，THE Video_Player_Page SHALL 使用 `assets/mp4/{pinyin}.mp4` 路径加载视频
3. WHEN 加载用户上传视频时，THE Video_Player_Page SHALL 使用 Local_Storage 中的 `{pinyin}.mp4` 路径加载视频
4. THE Character_Entry SHALL 保持汉字名称与拼音的一一对应关系

### 需求 4：视频播放适配

**用户故事：** 作为用户，我希望无论视频是内置的还是上传的，都能正常播放。

#### 验收标准

1. WHEN 播放 Video_Source 为 builtIn 的视频时，THE Video_Player_Page SHALL 使用 `VideoPlayerController.asset()` 加载视频
2. WHEN 播放 Video_Source 为 userUploaded 的视频时，THE Video_Player_Page SHALL 使用 `VideoPlayerController.file()` 从 Local_Storage 加载视频
3. IF 视频文件不存在或加载失败，THEN THE Video_Player_Page SHALL 显示"该视频暂不可用"的错误提示
4. THE Video_Player_Page SHALL 接收 Character_Entry 对象作为参数，替代当前的字符串参数

### 需求 5：设置页面 — 视频上传

**用户故事：** 作为用户，我希望能够通过设置页面上传自己的汉字书写视频，以便扩充学习内容。

#### 验收标准

1. THE Settings_Page SHALL 提供"添加汉字"功能入口
2. WHEN 用户点击"添加汉字"时，THE Settings_Page SHALL 显示表单，要求输入汉字名称和拼音
3. WHEN 用户填写汉字信息后，THE Settings_Page SHALL 允许用户从设备中选择一个 mp4 视频文件
4. WHEN 用户选择视频文件后，THE Settings_Page SHALL 将视频文件复制到 Local_Storage 并以 `{pinyin}.mp4` 命名
5. WHEN 视频文件复制完成后，THE Settings_Page SHALL 创建一个 Video_Source 为 userUploaded 的 Character_Entry 并保存到 Character_Repository
6. IF 用户输入的拼音与已有条目重复，THEN THE Settings_Page SHALL 提示用户该拼音已被使用
7. IF 用户选择的文件不是 mp4 格式，THEN THE Settings_Page SHALL 提示用户仅支持 mp4 格式

### 需求 6：设置页面 — 汉字管理

**用户故事：** 作为用户，我希望能够在设置页面查看和管理已有的汉字条目。

#### 验收标准

1. THE Settings_Page SHALL 显示所有已保存的 Character_Entry 列表
2. THE Settings_Page SHALL 在每个条目旁显示视频来源标识（内置或用户上传）
3. WHEN 用户长按或滑动一个 userUploaded 类型的条目时，THE Settings_Page SHALL 提供删除选项
4. WHEN 用户确认删除时，THE Settings_Page SHALL 从 Character_Repository 中移除该条目，并删除 Local_Storage 中对应的视频文件
5. THE Settings_Page SHALL 禁止删除 builtIn 类型的汉字条目

### 需求 7：导航集成

**用户故事：** 作为用户，我希望能够方便地从主页面进入设置页面。

#### 验收标准

1. THE CharacterListPage SHALL 在 AppBar 中显示一个设置图标按钮
2. WHEN 用户点击设置图标时，THE CharacterListPage SHALL 导航到 Settings_Page
3. WHEN 用户从 Settings_Page 返回时，THE CharacterListPage SHALL 刷新汉字列表以反映最新数据
