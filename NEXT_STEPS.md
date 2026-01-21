# 下一步操作指南 · Next Steps

## 当前状态

✅ **已完成**:
- Supabase CLI 已安装 (v2.72.7)
- Xcode 已安装
- 项目文件完整
- 启动脚本已准备

❌ **待完成**:
- Docker Desktop 需要安装

---

## 立即行动: 安装 Docker Desktop

### 方法 1: 直接下载（推荐）

1. **下载 Docker Desktop**
   - 访问: https://www.docker.com/products/docker-desktop
   - 点击 "Download for Mac"
   - 选择 "Apple Silicon" 版本（您的 Mac 使用 M 系列芯片）

2. **安装**
   - 打开下载的 `.dmg` 文件
   - 将 Docker 拖到 Applications 文件夹
   - 双击启动 Docker Desktop

3. **等待启动完成**
   - 首次启动需要几分钟
   - 顶部菜单栏出现 Docker 图标且不闪烁表示已就绪

### 方法 2: 使用 Homebrew

```bash
brew install --cask docker
```

然后从 Applications 文件夹启动 Docker。

---

## Docker 安装完成后

### 启动本地环境（一键启动）

```bash
cd /Users/tgmoon/github/died-or-not-scaffold
./start-local.sh
```

这个脚本会自动：
1. ✅ 验证所有工具已安装
2. 🚀 启动 Supabase（首次需要下载镜像，约 3-5 分钟）
3. 📦 应用数据库迁移
4. ⚙️  创建 .env 配置文件
5. 📋 显示访问信息

### 预期输出

启动成功后，您会看到：

```
🎉 步骤 5/5: 启动完成！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 访问地址:
   API URL: http://localhost:54321
   Studio:  http://localhost:54323

🔑 API Keys (已保存到 .env):
   Anon Key: eyJhbGc...

📱 运行 iOS 应用:
   1. 打开 Xcode:
      open ios/DiedOrNot
   ...
```

---

## 然后运行 iOS 应用

### 步骤 1: 打开项目

```bash
open ios/DiedOrNot
```

或者在 Finder 中双击 `ios/DiedOrNot/Package.swift`

### 步骤 2: 配置 Supabase 凭证

Xcode 会自动打开项目。找到并打开 `Config.swift` 文件。

**当前配置**:
```swift
enum Config {
    static let supabaseURL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "")!
    static let supabaseAnonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""
}
```

**需要改为**（使用本地启动脚本显示的值）:
```swift
enum Config {
    static let supabaseURL = URL(string: "http://localhost:54321")!
    static let supabaseAnonKey = "<从启动脚本输出中复制 anon key>"
}
```

### 步骤 3: 运行应用

1. 在 Xcode 顶部选择目标设备（如 iPhone 15 Pro）
2. 点击播放按钮或按 `⌘R`
3. 应用会在模拟器中启动

### 步骤 4: 测试功能

1. **观察控制台日志**
   - 应该看到 `✅ 匿名登录成功: <UUID>`
   - 应该看到 `✅ 用户记录创建成功`

2. **点击签到按钮**
   - 按钮应该变绿
   - 文字变为 "✓ 今日已签到"

3. **验证数据**
   - 打开浏览器访问 http://localhost:54323
   - 点击 "Table Editor"
   - 查看 `check_ins` 表，应该有一条新记录

---

## 访问 Supabase Studio

浏览器打开: http://localhost:54323

### 可以做什么

1. **Table Editor** - 查看和编辑表数据
   - 查看 `users` 表中的用户
   - 查看 `check_ins` 表中的签到记录

2. **SQL Editor** - 运行 SQL 查询
   ```sql
   -- 查看所有签到记录
   select * from check_ins order by created_at desc;

   -- 查看用户和最后签到时间
   select
     u.id,
     u.name,
     max(c.check_in_date) as last_check_in
   from users u
   left join check_ins c on u.id = c.user_id
   group by u.id, u.name;
   ```

3. **Authentication** - 查看所有匿名用户

4. **API Docs** - 查看自动生成的 API 文档

---

## 测试 Edge Functions（可选）

### 启动 Functions 服务

在新终端窗口：

```bash
cd /Users/tgmoon/github/died-or-not-scaffold
supabase functions serve
```

### 测试检查函数

在另一个终端：

```bash
# 获取 anon key
ANON_KEY=$(supabase status | grep "anon key:" | awk '{print $3}')

# 调用函数
curl -i http://localhost:54321/functions/v1/check-missed-check-ins \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json"
```

预期响应：
```json
{
  "success": true,
  "usersChecked": 1,
  "notificationsSent": 0,
  "timestamp": "2026-01-20T..."
}
```

---

## 常见问题

### Q: Docker Desktop 启动很慢？
A: 首次启动需要初始化，等待顶部菜单栏的 Docker 图标停止闪烁。

### Q: `supabase start` 卡住不动？
A:
1. 确认 Docker Desktop 正在运行
2. 重启 Docker Desktop
3. 运行 `docker ps` 确认 Docker 正常工作

### Q: iOS 应用无法连接？
A:
1. 确认 Supabase 正在运行：`supabase status`
2. 确认 Config.swift 中的 URL 是 `http://localhost:54321`
3. 查看 Xcode 控制台的错误信息

### Q: 签到后看不到数据？
A:
1. 打开 Supabase Studio: http://localhost:54323
2. 查看 Table Editor → check_ins
3. 如果为空，查看 Xcode 控制台的错误

---

## 停止本地环境

完成开发后：

```bash
# 停止 Supabase
supabase stop

# 或者停止并清除数据
supabase stop --no-backup
```

---

## 文档索引

- [README.md](README.md) - 项目介绍
- [QUICKSTART.md](QUICKSTART.md) - 快速启动指南
- [TESTING.md](TESTING.md) - 测试指南
- [DEPLOYMENT.md](DEPLOYMENT.md) - 部署指南
- [VERIFICATION_REPORT.md](VERIFICATION_REPORT.md) - 验证报告

---

## 需要帮助？

如果遇到问题：

1. **查看日志**
   ```bash
   # Supabase 日志
   supabase logs

   # Docker 日志
   docker ps
   docker logs <container_id>
   ```

2. **重新启动**
   ```bash
   supabase stop
   ./start-local.sh
   ```

3. **查看文档**
   - 本项目的文档非常完整
   - 遇到问题时先查阅相应文档

---

**当前需要您做的：安装 Docker Desktop，然后运行 `./start-local.sh`** 🚀
