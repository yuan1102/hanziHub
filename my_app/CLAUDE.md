# Claude Code 项目上下文说明
项目名称：my_app
项目类型：Flutter 儿童识字学习应用
目标用户：儿童（学龄前 / 小学生低年级）

---

# 一、项目整体说明

本项目是一个用于儿童学习汉字的教育类应用。

核心功能包括：

1. 汉字学习流程
2. 拼音声调展示
3. 汉字相关视频存储与播放

所有设计规格说明位于：

.kiro/specs/
    ├── character-video-storage
    ├── kids-character-learning
    └── pinyin-tone-display

Claude 在修改任何模块前，必须先阅读对应 specs 文档。

---

# 二、模块职责划分

## 1️⃣ character-video-storage

职责：
- 汉字视频资源管理
- 本地 / 远程视频处理
- 视频缓存逻辑
- 视频播放协调

修改该模块时：
- 不得破坏离线播放能力
- 不得硬编码路径
- 不得删除缓存机制

---

## 2️⃣ kids-character-learning

职责：
- 学习流程控制
- 页面交互
- 学习进度记录
- 课程组织结构

修改该模块时：
- 不得重置用户学习数据
- 不得破坏进度持久化
- 保证 UI 流畅

---

## 3️⃣ pinyin-tone-display

职责：
- 拼音格式转换
- 声调符号处理（ā á ǎ à）
- 多音字支持
- 拼音渲染逻辑

修改该模块时：
- 必须保证声调准确
- 不得降低文本渲染性能
- 不得破坏多音字兼容

---

# 三、数据模型规范

可能存在核心数据模型：

CharacterEntry:
    - name: String              # 汉字（如"天"）
    - pinyin: String            # 无声调拼音（如"tian"），由 lpinyin 自动生成
    - videoSource: VideoSource  # builtIn | userUploaded
    - learnStatus: LearnStatus  # unlearned | learned | mastered（三态学习状态）

LearnStatus 枚举:
    - unlearned: 未学习（默认）
    - learned: 已学习
    - mastered: 已掌握
    长按卡片循环切换：unlearned → learned → mastered → unlearned

派生属性:
    - tonedPinyin: 带声调拼音（如"tiān"），由 getTonedPinyinFromChar() 实时生成
    - videoPath: 内置为 "assets/mp4/$name.mp4"，用户上传为 "$name.mp4"

修改数据模型时必须：

- 保持向后兼容
- 不破坏序列化
- 同步更新依赖模块

---

# 四、状态管理规则

Claude 必须先识别当前使用的状态管理方式：

- Provider
- Riverpod
- Bloc
- GetX
- setState

⚠ 禁止在未明确要求的情况下引入新的状态管理框架。

---

# 五、修改代码时的硬性规则

1. 不得整体重构架构（除非明确要求）
2. 不得随意修改路由名称
3. 不得破坏 null-safety
4. 保持 Flutter 版本兼容
5. 代码必须可维护、可扩展
6. 不删除原有注释

---

# 六、性能要求

- 不在 build() 中做重计算
- 避免阻塞 UI 线程
- 使用 async / await
- 保持滚动流畅
- 视频播放不卡顿

---

# 七、修改前流程（强制）

在进行较大改动前，Claude 必须：

1. 先总结当前模块结构
2. 说明修改影响范围
3. 给出安全修改方案
4. 再进行代码修改

---

# 八、禁止行为（STRICT MODE）

Claude 不得：

- 重写整个模块
- 替换项目架构
- 修改文件夹结构
- 引入大型依赖库
- 删除已有功能
- 重命名公共 API

除非用户明确要求。

---

# 九、未来扩展方向

架构需保持可扩展性，用于：

- AI 语音识别
- 智能复习算法
- 云端同步
- 多语言支持

UI 与业务逻辑必须保持解耦。

---

# 十、优先级原则

本项目优先级排序：

稳定性 > 可维护性 > 可扩展性 > 优化重构

这是一个儿童教育类生产级应用，
安全修改比“炫技式重构”更重要。