# 快速启动指南 · Quick Start Guide

本文档提供最快速的方式让项目运行起来。

---

## 前置检查

运行验证脚本检查项目完整性：

```bash
./verify.sh
```

---

## 步骤 1: 安装必要工具

### macOS

```bash
# 安装 Homebrew（如果还没安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 Supabase CLI
brew install supabase/tap/supabase

# 安装 Deno（可选，用于本地测试 Edge Functions）
brew install deno

# 安装 Docker Desktop
# 下载地址: https://www.docker.com/products/docker-desktop
```

### 验证安装

```bash
supabase --version
docker --version
deno --version
```

---

## 步骤 2: 选择运行方式

### 方式 A: 本地开发环境（推荐用于学习和测试）

#### 1. 启动 Docker Desktop

确保 Docker Desktop 正在运行。

#### 2. 启动本地 Supabase

```bash
# 进入项目目录
cd /Users/tgmoon/github/died-or-not-scaffold

# 启动 Supabase（首次启动会下载镜像，需要几分钟）
supabase start
```

**重要**：记下输出的凭证信息！

输出示例：
```
Started supabase local development setup.

         API URL: http://localhost:54321
          DB URL: postgresql://postgres:postgres@localhost:54322/postgres
      Studio URL: http://localhost:54323
    Inbucket URL: http://localhost:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: eyJhbGc...
service_role key: eyJhbGc...
```

#### 3. 应用数据库迁移

```bash
supabase db reset
```

这会创建 `users` 和 `check_ins` 表，并配置 RLS 策略。

#### 4. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，填入上面的本地凭证
nano .env
```

填入内容：
```
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=<上面显示的 anon key>
SUPABASE_SERVICE_ROLE_KEY=<上面显示的 service_role key>
```

#### 5. 访问 Supabase Studio

打开浏览器访问：http://localhost:54323

在 Studio 中可以：
- 查看表结构（Table Editor）
- 运行 SQL 查询（SQL Editor）
- 查看 API 文档（API Docs）
- 查看认证用户（Authentication）

#### 6. 配置并运行 iOS 应用

打开 [ios/DiedOrNot/Config.swift](ios/DiedOrNot/Config.swift)，修改为：

```swift
enum Config {
    static let supabaseURL = URL(string: "http://localhost:54321")!
    static let supabaseAnonKey = "<你的 anon key>"
}
```

在 Xcode 中打开项目：

```bash
open ios/DiedOrNot
```

在 Xcode 中：
1. 选择模拟器（iPhone 15 Pro 或任意设备）
2. 点击 Run (⌘R)
3. 应用将启动并自动匿名登录

#### 7. 测试签到功能

1. 在应用中点击"签到"按钮
2. 返回 Supabase Studio
3. 在 Table Editor 中查看 `check_ins` 表
4. 应该能看到新的签到记录

#### 8. 测试 Edge Functions（可选）

```bash
# 启动 Functions 服务（在新终端）
supabase functions serve

# 在另一个终端测试函数
curl -i --location --request POST \
  'http://localhost:54321/functions/v1/check-missed-check-ins' \
  --header 'Authorization: Bearer <ANON_KEY>' \
  --header 'Content-Type: application/json'
```

---

### 方式 B: 使用云端 Supabase（推荐用于生产部署）

#### 1. 创建 Supabase 项目

1. 访问 https://supabase.com
2. 注册/登录账号
3. 点击 "New Project"
4. 填写项目信息（名称、密码、地区）
5. 等待项目创建完成（约 2 分钟）

#### 2. 获取项目凭证

在项目首页：
1. 点击左侧菜单 "Settings"
2. 点击 "API"
3. 复制以下信息：
   - Project URL
   - anon / public key
   - service_role key（点击显示）

#### 3. 登录并关联项目

```bash
# 登录 Supabase
supabase login

# 关联到你的项目
# Project Ref 可以在项目 URL 中找到: https://[project-ref].supabase.co
supabase link --project-ref <你的project-ref>
```

#### 4. 一键部署

```bash
./deploy.sh
```

这会自动：
- 推送数据库迁移
- 部署 Edge Functions
- 显示部署结果

#### 5. 配置 Edge Functions 环境变量

在 Supabase 控制台：
1. 进入 "Edge Functions" → "Settings"
2. 添加 Secrets：
   ```
   SUPABASE_URL=https://<你的项目>.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=<你的 service_role key>
   ```

#### 6. 配置定时任务

在 Supabase SQL Editor 中：
1. 打开 [supabase/setup-cron.sql](supabase/setup-cron.sql)
2. 替换 `<YOUR_PROJECT>` 和 `<SERVICE_ROLE_KEY>`
3. 执行 SQL

验证：
```sql
select * from cron.job;
```

#### 7. 配置 iOS 应用

在 [ios/DiedOrNot/Config.swift](ios/DiedOrNot/Config.swift) 中：

```swift
enum Config {
    static let supabaseURL = URL(string: "https://<你的项目>.supabase.co")!
    static let supabaseAnonKey = "<你的 anon key>"
}
```

运行应用进行测试。

---

## 步骤 3: 验证功能

### 验证清单

- [ ] iOS 应用启动成功
- [ ] 自动匿名登录（查看 Xcode 控制台日志）
- [ ] 签到功能正常
- [ ] Supabase Studio 中可以看到数据
- [ ] 防重复签到生效（当天第二次签到会失败）
- [ ] Edge Functions 可以调用
- [ ] 定时任务已配置（云端模式）

### 查看日志

**iOS 应用日志**：
- 在 Xcode 控制台查看
- 查找 `✅`、`❌` 标记的日志

**Edge Functions 日志**（本地）：
```bash
supabase functions logs check-missed-check-ins
```

**Edge Functions 日志**（云端）：
- 在 Supabase 控制台 → Edge Functions → Logs

**数据库查询**：
```sql
-- 查看所有用户
select * from users;

-- 查看所有签到记录
select * from check_ins order by created_at desc;

-- 查看用户的最后签到时间
select
  u.id,
  u.name,
  max(c.check_in_date) as last_check_in
from users u
left join check_ins c on u.id = c.user_id
group by u.id, u.name;
```

---

## 常见问题

### Q: `supabase start` 卡住不动？

A: 检查 Docker Desktop 是否正在运行，重启 Docker 后重试。

### Q: iOS 应用无法连接 Supabase？

A:
1. 检查 URL 和 API Key 是否正确
2. 本地环境确保使用 `http://localhost:54321`
3. 查看 Xcode 控制台的错误信息

### Q: 签到后看不到数据？

A:
1. 检查 RLS 策略是否正确应用
2. 在 SQL Editor 中直接查询验证
3. 查看 Xcode 日志中的错误信息

### Q: Edge Functions 调用失败？

A:
1. 检查 Authorization header 是否正确
2. 本地模式确保 `supabase functions serve` 正在运行
3. 云端模式检查环境变量是否配置

---

## 停止本地环境

```bash
# 停止 Supabase
supabase stop

# 停止并清除所有数据
supabase stop --no-backup
```

---

## 下一步

现在你的项目已经运行起来了！接下来可以：

1. **学习代码结构**
   - 查看 [ios/DiedOrNot/Services/SupabaseManager.swift](ios/DiedOrNot/Services/SupabaseManager.swift) 了解 Supabase 集成
   - 查看 [supabase/functions](supabase/functions) 了解 Edge Functions

2. **添加新功能**
   - 参考 [README.md](README.md) 第九节的扩展建议
   - 修改代码并测试

3. **部署到生产**
   - 按照方式 B 部署到云端 Supabase
   - 发布 iOS 应用到 TestFlight / App Store

4. **深入学习**
   - 阅读 [TESTING.md](TESTING.md) 了解测试方法
   - 阅读 [DEPLOYMENT.md](DEPLOYMENT.md) 了解部署细节

---

需要帮助？

- 查看 [README.md](README.md) 了解项目概述
- 查看 [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) 了解项目完成情况
- 提交 Issue 寻求帮助

Happy Hacking! 🚀
