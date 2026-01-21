# Xcode 使用指南

## Xcode 界面布局

```
┌─────────────────────────────────────────────────────────┐
│ ▶️ [■] DiedOrNot > iPhone 15 Pro    [编译状态]        │ ← 工具栏
├─────────────────────────────────────────────────────────┤
│                                                         │
│  左侧面板          │    中间编辑区域    │   右侧面板    │
│  (文件导航)        │    (代码编辑)      │   (检查器)    │
│                    │                   │               │
│  📁 DiedOrNot      │  import SwiftUI   │  File Info    │
│    📁 App          │                   │               │
│    📁 Services     │  struct CheckIn.. │  Properties   │
│    📁 Views        │  {                │               │
│                    │    ...            │               │
├────────────────────┴───────────────────┴───────────────┤
│  控制台 / 调试区域 (按 ⌘⇧Y 显示/隐藏)                   │
│  ✅ 匿名登录成功: ABC123...                              │
│  ✅ 用户记录创建成功                                     │
└─────────────────────────────────────────────────────────┘
```

## 关键操作

### 1. 运行应用
- **播放按钮**: 左上角 ▶️
- **快捷键**: `⌘R` (Command + R)
- **停止**: `⌘.` (Command + 句号)

### 2. 选择设备
- 点击 "DiedOrNot > [设备]" 下拉菜单
- 选择任意 iOS 模拟器

### 3. 查看日志
- **显示/隐藏控制台**: `⌘⇧Y`
- **清空日志**: 控制台右下角垃圾桶图标
- **搜索日志**: 控制台右上角搜索框

### 4. 查看文件
- **显示/隐藏左侧面板**: `⌘0` (Command + 0)
- **文件导航**: `⌘1` (Command + 1)
- **搜索文件**: `⌘⇧O` (Command + Shift + O)

### 5. 编译相关
- **清理构建**: `⌘⇧K` (Command + Shift + K)
- **构建**: `⌘B` (Command + B)
- **运行**: `⌘R` (Command + R)

## 运行步骤（详细）

### 第 1 步: 打开项目
```bash
cd /Users/tgmoon/github/died-or-not-scaffold
open ios/DiedOrNot
```

### 第 2 步: 等待准备完成
Xcode 顶部会显示：
- "Indexing..." → 索引代码
- "Resolving Package Dependencies..." → 下载依赖
- "Ready" → 准备完成

**时间**: 首次打开约 1-2 分钟

### 第 3 步: 选择模拟器
1. 点击工具栏中间的设备选择器
2. 在下拉菜单中选择：
   - iOS Simulators → iPhone 15 Pro
   - 或其他 iOS 17+ 设备

### 第 4 步: 运行
1. 点击 ▶️ 按钮（或按 `⌘R`）
2. 等待编译（首次编译约 1-2 分钟）
3. 模拟器会自动启动
4. 应用自动安装并运行

### 第 5 步: 查看日志
1. 按 `⌘⇧Y` 打开控制台
2. 查看输出日志：
   ```
   ✅ 匿名登录成功: ABC123-DEF456...
   ✅ 用户记录创建成功
   ```

### 第 6 步: 测试功能
在模拟器中：
1. 点击"签到"按钮
2. 观察按钮变化
3. 查看控制台日志

## 故障排查

### 问题 1: 编译失败
**症状**: Xcode 显示红色错误

**解决方法**:
1. 清理构建: `⌘⇧K`
2. 重新构建: `⌘B`
3. 如果还是失败，把错误信息发给我

### 问题 2: 依赖下载失败
**症状**: "Package resolution failed"

**解决方法**:
1. Xcode 菜单 → File → Packages → Reset Package Caches
2. 重新打开项目

### 问题 3: 模拟器启动慢
**症状**: 点击运行后等很久

**解决方法**:
1. 首次启动模拟器确实较慢（1-2 分钟）
2. 可以预先启动: Xcode → Window → Devices and Simulators → 选择模拟器 → 点击播放按钮

### 问题 4: 应用闪退
**症状**: 应用启动后立即关闭

**解决方法**:
1. 查看控制台错误信息
2. 检查 Config.swift 中的 URL 和 API Key 是否正确
3. 把错误信息发给我

### 问题 5: 找不到控制台
**症状**: 看不到日志输出

**解决方法**:
1. 按 `⌘⇧Y` 显示底部面板
2. 点击右侧 "Console" 标签
3. 或者 Xcode 菜单 → View → Debug Area → Show Debug Area

## 常用快捷键速查

| 功能 | 快捷键 |
|------|--------|
| 运行 | `⌘R` |
| 停止 | `⌘.` |
| 构建 | `⌘B` |
| 清理 | `⌘⇧K` |
| 显示/隐藏控制台 | `⌘⇧Y` |
| 显示/隐藏左侧栏 | `⌘0` |
| 快速打开文件 | `⌘⇧O` |
| 搜索 | `⌘F` |
| 全局搜索 | `⌘⇧F` |

## 查看项目文件

### 在 Xcode 中查看文件:
1. 左侧面板显示文件树
2. 点击文件名即可打开编辑

### 关键文件位置:
- **Config.swift**: 配置文件（URL 和 API Key）
- **DiedOrNotApp.swift**: 应用入口
- **SupabaseManager.swift**: Supabase 客户端
- **CheckInView.swift**: 主界面

## 验证配置

### 检查 Config.swift
1. 在左侧文件树中找到 `Config.swift`
2. 点击打开
3. 确认内容：
   ```swift
   enum Config {
       static let supabaseURL = URL(string: "https://frcoxpkhkobidepdcsbc.supabase.co")!
       static let supabaseAnonKey = "sb_publishable_EnWQYOTnu5bmNLWZra-Eww_RFldmpPL"
   }
   ```

### 修改配置（如果需要）
1. 直接在编辑器中修改
2. `⌘S` 保存
3. 重新运行 `⌘R`

## 下一步

运行成功后：
1. 测试签到功能
2. 在 Supabase 控制台查看数据
3. 如有问题，发送控制台日志给我

---

**准备好了吗？按 `⌘R` 运行应用！** 🚀
