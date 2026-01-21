# 云端 Supabase 设置指南

## 第一步：创建 Supabase 项目

1. **访问**: https://supabase.com
2. **登录/注册** (可用 GitHub 快速登录)
3. **创建项目**:
   - 点击 "New Project"
   - Name: `died-or-not`
   - Database Password: 设置强密码（记住它）
   - Region: Northeast Asia (Seoul) 或 Southeast Asia (Singapore)
   - 点击 "Create new project"
   - 等待 2 分钟

---

## 第二步：获取 Access Token

1. 在 Supabase 控制台，点击右上角头像
2. 点击 "Account Settings"
3. 在左侧菜单点击 "Access Tokens"
4. 点击 "Generate new token"
5. Name: `cli-access`
6. 点击 "Generate Token"
7. **复制显示的 token**（只显示一次！）

---

## 第三步：登录 CLI

在终端运行：

```bash
supabase login --token <你复制的token>
```

---

## 第四步：获取项目信息

1. 在 Supabase 控制台，回到项目首页
2. 点击左侧 "Settings" → "API"
3. 记录以下信息：
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Project API keys → anon public**: `eyJhbGc...`
   - **Project API keys → service_role**: 点击 "Reveal" 查看并复制

4. 找到 **Project Reference ID**:
   - 在项目 URL 中: `https://[这部分就是ref].supabase.co`
   - 或在 Settings → General → Reference ID

---

## 第五步：关联项目

```bash
cd /Users/tgmoon/github/died-or-not-scaffold
supabase link --project-ref <你的project-ref>
```

会提示输入数据库密码（第一步设置的密码）。

---

## 第六步：一键部署

```bash
./deploy.sh
```

这会自动：
- 推送数据库迁移（创建表和 RLS 策略）
- 部署 Edge Functions

---

## 第七步：配置 iOS 应用

编辑 `ios/DiedOrNot/Config.swift`：

```swift
enum Config {
    static let supabaseURL = URL(string: "https://xxxxx.supabase.co")!  // 你的 Project URL
    static let supabaseAnonKey = "eyJhbGc..."  // 你的 anon key
}
```

---

## 第八步：运行 iOS 应用

```bash
open ios/DiedOrNot
```

在 Xcode 中：
1. 选择模拟器（iPhone 15 Pro）
2. 按 ⌘R 运行
3. 测试签到功能

---

## 验证

1. **查看数据库**:
   - Supabase 控制台 → Table Editor
   - 查看 `users` 和 `check_ins` 表

2. **测试 Edge Function**:
   ```bash
   curl -i --location --request POST \
     'https://xxxxx.supabase.co/functions/v1/check-missed-check-ins' \
     --header "Authorization: Bearer <你的 anon key>" \
     --header 'Content-Type: application/json'
   ```

---

## 下一步（可选）

### 配置定时任务

在 Supabase SQL Editor 中：

1. 打开 `supabase/setup-cron.sql`
2. 替换 `<YOUR_PROJECT>` 和 `<SERVICE_ROLE_KEY>`
3. 执行 SQL

验证：
```sql
select * from cron.job;
```

---

完成！现在你的项目已经在云端运行了 🚀
