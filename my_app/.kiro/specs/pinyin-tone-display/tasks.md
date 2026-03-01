# 实现计划：拼音声调显示功能

## 概述

本实现计划将为儿童汉字学习应用添加带声调拼音显示功能。核心策略是扩展现有的 chargeMap 数据结构，从简单的字符串映射升级为包含汉字和带声调拼音的结构化数据，同时保持向后兼容性和文件系统稳定性。

## 任务

- [x] 1. 创建 CharacterInfo 数据类和更新 chargeMap
  - [x] 1.1 在 character_repository.dart 中创建 CharacterInfo 数据类
    - 定义包含 character 和 tonedPinyin 字段的不可变数据类
    - 使用 const 构造函数以支持编译时常量
    - _需求: 1.1, 1.2_
  
  - [x] 1.2 将 chargeMap 从 Map<String, String> 迁移到 Map<String, CharacterInfo>
    - 更新所有现有条目为 CharacterInfo 格式
    - 添加带声调拼音数据（bā, bái, lǜ, nǚ 等）
    - 正确处理多音字（de/de1, mi/mi1, you/you1, guo/guo1, xiang/xiang1）
    - 正确处理轻声（de -> 'de'）
    - 正确处理 ü 的表示（lv -> 'lǜ', nv -> 'nǚ'）
    - _需求: 1.1, 1.2, 1.4, 6.1, 6.2, 6.3_
  
  - [x] 1.3 实现 getCharacter 辅助方法
    - 接受 String pinyin 参数
    - 返回 chargeMap 中对应的汉字
    - 如果拼音不存在，返回原始输入（回退行为）
    - _需求: 1.3, 4.3_
  
  - [x] 1.4 实现 getTonedPinyin 辅助方法
    - 接受 String pinyin 参数
    - 返回 chargeMap 中对应的带声调拼音
    - 如果拼音不存在，返回原始输入（回退行为）
    - _需求: 1.1, 1.3_
  
  - [ ]* 1.5 编写 CharacterInfo 和 chargeMap 的单元测试
    - 测试 CharacterInfo 数据类的创建和字段访问
    - 测试特定示例（'lv' -> CharacterInfo('绿', 'lǜ')）
    - 测试多音字处理（'de' vs 'de1', 'mi' vs 'mi1'）
    - 测试四个声调的代表性示例
    - 测试轻声处理
    - 验证 chargeMap 完整性（所有条目都有非空汉字和拼音）
    - _需求: 1.1, 1.2, 1.4, 6.1, 6.2, 6.3_
  
  - [ ]* 1.6 编写属性测试：chargeMap 数据完整性
    - **属性 1: chargeMap 数据完整性**
    - **验证需求: 1.1**
    - 对于任何 chargeMap 中的条目，character 和 tonedPinyin 都应该是非空字符串
  
  - [ ]* 1.7 编写属性测试：未映射拼音的回退行为
    - **属性 2: 未映射拼音的回退行为**
    - **验证需求: 1.3**
    - 对于任何不在 chargeMap 中的拼音，getTonedPinyin 应返回原始输入
  
  - [ ]* 1.8 编写属性测试：getTonedPinyin 的幂等性
    - **属性 11: getTonedPinyin 的幂等性**
    - **验证需求: 1.1**
    - 对于任何拼音字符串，多次调用 getTonedPinyin 应返回相同结果

- [x] 2. 更新 CharacterRepository 使用新的辅助方法
  - [x] 2.1 更新 _scanBuiltInVideos 方法
    - 将 `chargeMap[pinyin] ?? pinyin` 替换为 `getCharacter(pinyin)`
    - 确保所有内置视频条目正确关联汉字
    - _需求: 4.2, 4.3_
  
  - [ ]* 2.2 编写 Repository 集成测试
    - 测试 _scanBuiltInVideos 使用 getCharacter 方法
    - 测试 JSON 加载和保存功能
    - 测试错误恢复机制
    - _需求: 4.1, 4.2, 4.3_
  
  - [ ]* 2.3 编写属性测试：Repository 保持 chargeMap 映射
    - **属性 10: Repository 保持 chargeMap 映射**
    - **验证需求: 4.3**
    - 对于任何在 chargeMap 中的拼音，创建的 CharacterEntry 的 name 应等于对应的汉字
  
  - [ ]* 2.4 编写属性测试：Repository 加载 JSON 的幂等性
    - **属性 9: Repository 加载 JSON 的幂等性**
    - **验证需求: 4.1**
    - 对于任何有效的 characters.json 文件，多次调用 loadCharacters 应返回相同结果

- [-] 3. 扩展 CharacterEntry 模型
  - [x] 3.1 在 CharacterEntry 中添加 tonedPinyin getter
    - 实现 `String get tonedPinyin => getTonedPinyin(pinyin);`
    - 确保不修改构造函数和序列化逻辑
    - _需求: 2.1, 2.3_
  
  - [ ]* 3.2 编写 CharacterEntry 单元测试
    - 测试 tonedPinyin getter 返回正确的带声调拼音
    - 测试 videoPath 继续使用简化拼音
    - 测试序列化和反序列化保持不变
    - _需求: 2.1, 2.2, 2.4_
  
  - [ ]* 3.3 编写属性测试：CharacterEntry 序列化往返
    - **属性 3: CharacterEntry 序列化往返**
    - **验证需求: 2.4**
    - 对于任何 CharacterEntry，序列化后再反序列化应得到等价对象
  
  - [ ]* 3.4 编写属性测试：CharacterEntry 使用简化拼音作为文件路径
    - **属性 4: CharacterEntry 使用简化拼音作为文件路径**
    - **验证需求: 2.2, 4.4**
    - 对于任何 CharacterEntry，videoPath 应包含 pinyin 字段而非 tonedPinyin
  
  - [ ]* 3.5 编写属性测试：CharacterEntry 提供带声调拼音访问
    - **属性 5: CharacterEntry 提供带声调拼音访问**
    - **验证需求: 2.1, 2.3**
    - 对于任何有效拼音创建的 CharacterEntry，tonedPinyin getter 应返回非空字符串

- [ ] 4. 检查点 - 确保核心数据层测试通过
  - 确保所有测试通过，如有问题请询问用户

- [x] 5. 更新 CharacterCard UI 显示拼音
  - [x] 5.1 更新 CharacterCard 布局结构
    - 将 Center 中的单个 Text 改为 Column 布局
    - 添加拼音 Text widget（character.tonedPinyin）
    - 添加汉字 Text widget（character.name）
    - 设置拼音字体大小为 20，颜色为 Colors.black54
    - 设置汉字字体大小为 48，粗体
    - 在拼音和汉字之间添加 4px 间距
    - 确保拼音位于汉字上方
    - _需求: 3.1, 3.2, 3.3, 3.4_
  
  - [ ]* 5.2 编写 CharacterCard widget 测试
    - 测试渲染包含 tonedPinyin 和 name 的 Text widgets
    - 测试字体大小和样式正确
    - 测试布局结构（Column, 间距）
    - _需求: 3.1, 3.2, 3.3, 3.4_
  
  - [ ]* 5.3 编写属性测试：CharacterCard 同时显示汉字和拼音
    - **属性 6: CharacterCard 同时显示汉字和拼音**
    - **验证需求: 3.1, 3.2**
    - 对于任何 CharacterEntry，渲染的 CharacterCard 应包含 name 和 tonedPinyin 的 Text widgets
  
  - [ ]* 5.4 编写属性测试：CharacterCard 视觉层次正确
    - **属性 7: CharacterCard 视觉层次正确**
    - **验证需求: 3.4**
    - 对于任何 CharacterEntry，汉字的字体大小应大于拼音的字体大小
  
  - [ ]* 5.5 编写属性测试：CharacterCard 拼音字体可读
    - **属性 8: CharacterCard 拼音字体可读**
    - **验证需求: 3.3**
    - 对于任何 CharacterEntry，拼音的字体大小应至少为 16

- [ ] 6. 最终检查点 - 端到端验证
  - 确保所有测试通过，如有问题请询问用户

## 注意事项

- 标记 `*` 的任务为可选测试任务，可以跳过以加快 MVP 开发
- 每个任务都引用了具体的需求编号以确保可追溯性
- 检查点任务确保增量验证
- 属性测试验证通用正确性属性
- 单元测试验证特定示例和边缘情况
- 所有实现保持向后兼容性，不修改文件系统结构
