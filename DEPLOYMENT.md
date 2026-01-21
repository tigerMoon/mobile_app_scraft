# 部署指南 · Deployment Guide

本文档说明如何部署「死了么」应用到生产环境。

## 前置要求

1. 安装 [Supabase CLI](https://supabase.com/docs/guides/cli)
   ```bash
   brew install supabase/tap/supabase
   ```

2. 安装 [Deno](https://deno.land/)（用于 Edge Functions）
   ```bash
   curl -fsSL https://deno.land/install.sh | sh
   ```

3. 注册 [Supabase](https://supabase.com) 账号并创建项目

---

## 一、配置 Supabase 项目

### 1.1 登录 Supabase CLI

```bash
supabase login
```

### 1.2 关联项目

```bash
# 如果是新项目，需要初始化
supabase init

# 关联到远程 Supabase 项目
supabase link --project-ref <你的项目ID>
```

你的项目 ID 可以在 Supabase 控制台找到，格式类似 `abcdefghijklmnop`

---

## 二、数据库迁移

### 2.1 推送数据库结构

```bash
supabase db push
```

这将执行 `supabase/migrations/` 中的所有迁移文件：
- `001_init.sql` - 创建表结构
- `002_rls.sql` - 配置行级安全策略

### 2.2 验证数据库

在 Supabase 控制台中打开 Table Editor，应该能看到：
- `users` 表
- `check_ins` 表
- RLS 策略已启用

---

## 三、部署 Edge Functions

### 3.1 部署函数

```bash
# 部署所有函数
supabase functions deploy check-missed-check-ins
supabase functions deploy send-notification-email
```

### 3.2 设置环境变量

在 Supabase 控制台 → Settings → Edge Functions → Secrets，添加：

```
SUPABASE_URL=https://<你的项目>.supabase.co
SUPABASE_SERVICE_ROLE_KEY=<你的Service Role Key>
```

### 3.3 测试函数

```bash
# 测试检查未签到函数
curl -i --location --request POST \
  'https://<你的项目>.supabase.co/functions/v1/check-missed-check-ins' \
  --header 'Authorization: Bearer <ANON_KEY>'
```

---

## 四、配置定时任务

### 4.1 在 Supabase 控制台配置 Cron Job

1. 进入 Supabase 控制台
2. 导航到 Database → Extensions
3. 启用 `pg_cron` 扩展
4. 在 SQL Editor 中执行：

```sql
-- 每天早上 9 点检查未签到用户
select cron.schedule(
  'check-missed-check-ins',
  '0 9 * * *',  -- 每天 9:00 AM (UTC)
  $$
  select
    net.http_post(
      url := 'https://<你的项目>.supabase.co/functions/v1/check-missed-check-ins',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer <SERVICE_ROLE_KEY>'
      )
    ) as request_id;
  $$
);
```

### 4.2 查看定时任务

```sql
select * from cron.job;
```

---

## 五、配置 iOS 应用

### 5.1 创建 .env 文件

在项目根目录创建 `.env` 文件：

```bash
SUPABASE_URL=https://<你的项目>.supabase.co
SUPABASE_ANON_KEY=<你的Anon Key>
SUPABASE_SERVICE_ROLE_KEY=<你的Service Role Key>
```

### 5.2 获取 API Keys

在 Supabase 控制台 → Settings → API：
- `anon` / `public` key - 用于客户端
- `service_role` key - 用于服务端（Edge Functions）

### 5.3 配置 Xcode

1. 打开 `ios/DiedOrNot` 目录
2. 使用 Xcode 打开项目
3. 在 Build Phases → Run Script 中添加环境变量加载脚本（可选）

或者直接在代码中配置（[Config.swift](ios/DiedOrNot/Config.swift)）：

```swift
enum Config {
    static let supabaseURL = URL(string: "https://<你的项目>.supabase.co")!
    static let supabaseAnonKey = "<你的Anon Key>"
}
```

---

## 六、测试完整流程

### 6.1 测试匿名登录

运行 iOS 应用，应该自动完成匿名登录。

### 6.2 测试签到功能

1. 点击"签到"按钮
2. 在 Supabase 控制台 Table Editor 中查看 `check_ins` 表
3. 应该能看到新的签到记录

### 6.3 测试通知功能

手动触发检查函数：

```bash
curl -X POST \
  'https://<你的项目>.supabase.co/functions/v1/check-missed-check-ins' \
  -H 'Authorization: Bearer <ANON_KEY>'
```

---

## 七、监控和日志

### 7.1 查看 Edge Functions 日志

```bash
supabase functions logs check-missed-check-ins
```

或在 Supabase 控制台 → Edge Functions → Logs

### 7.2 查看数据库日志

在 Supabase 控制台 → Logs → Database

---

## 八、常见问题

### Q: RLS 策略阻止了操作怎么办？

A: 确保在创建用户记录时使用了正确的 user_id（来自 auth.uid()）

### Q: 定时任务没有执行？

A: 检查：
1. `pg_cron` 扩展是否启用
2. Cron 表达式是否正确
3. Edge Function URL 是否正确
4. Service Role Key 是否配置

### Q: iOS 应用无法连接 Supabase？

A: 检查：
1. URL 和 API Key 是否正确
2. 网络权限配置（Info.plist）
3. 是否在模拟器/真机上测试

---

## 九、安全提示

1. ⚠️ **永远不要提交** `.env` 文件到 Git
2. ⚠️ **永远不要在客户端代码中硬编码** Service Role Key
3. ⚠️ **使用 RLS** 保护所有数据表
4. ⚠️ **定期轮换** API Keys

---

## 十、下一步

- [ ] 集成真实的邮件服务（SendGrid / AWS SES）
- [ ] 添加推送通知支持
- [ ] 实现用户资料编辑功能
- [ ] 添加统计和分析功能

---

需要帮助？查看 [Supabase 文档](https://supabase.com/docs) 或提交 Issue。
