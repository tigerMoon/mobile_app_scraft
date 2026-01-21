# 手动部署 Edge Functions 指南

由于网络问题无法通过 CLI 部署 Edge Functions，请按照以下步骤在 Supabase 控制台手动部署。

---

## 方法 1: 通过控制台创建（推荐）

### 部署 check-missed-check-ins 函数

1. **打开 Supabase 控制台**: https://supabase.com/dashboard/project/frcoxpkhkobidepdcsbc

2. **进入 Edge Functions**:
   - 左侧菜单点击 "Edge Functions"
   - 点击 "Create a new function"

3. **创建函数**:
   - Name: `check-missed-check-ins`
   - 点击 "Create function"

4. **粘贴代码**:
   - 打开本地文件: `supabase/functions/check-missed-check-ins/index.ts`
   - 复制全部内容
   - 粘贴到控制台编辑器
   - 点击 "Deploy"

### 部署 send-notification-email 函数

重复上述步骤，使用：
- Name: `send-notification-email`
- 代码: `supabase/functions/send-notification-email/index.ts`

---

## 方法 2: 使用 Supabase GitHub 集成（自动部署）

如果你的项目在 GitHub 上：

1. **连接 GitHub**:
   - Supabase 控制台 → Settings → CI/CD
   - 点击 "Connect to GitHub"
   - 授权并选择仓库

2. **配置自动部署**:
   - Supabase 会自动检测 `supabase/functions` 目录
   - 每次 push 到 main 分支都会自动部署

---

## 配置环境变量（重要）

部署完成后，需要配置函数使用的环境变量：

1. **进入 Edge Functions 设置**:
   - Edge Functions → Settings
   - 或直接访问: https://supabase.com/dashboard/project/frcoxpkhkobidepdcsbc/settings/functions

2. **添加 Secrets**:
   点击 "Add secret" 添加以下变量：

   ```
   SUPABASE_URL=https://frcoxpkhkobidepdcsbc.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=<你的 service_role key>
   ```

3. **获取 service_role key**:
   - Settings → API
   - 找到 "service_role" key
   - 点击 "Reveal" 并复制

---

## 测试函数

### 测试 check-missed-check-ins

在控制台或使用 curl：

```bash
curl -i --location --request POST \
  'https://frcoxpkhkobidepdcsbc.supabase.co/functions/v1/check-missed-check-ins' \
  --header 'Authorization: Bearer <你的 anon key>' \
  --header 'Content-Type: application/json'
```

预期响应：
```json
{
  "success": true,
  "usersChecked": 0,
  "notificationsSent": 0,
  "timestamp": "2026-01-20T..."
}
```

---

## 配置定时任务（可选）

在 SQL Editor 中执行 `supabase/setup-cron.sql`（记得替换项目 URL 和 service_role key）。

---

## 获取函数代码

### check-missed-check-ins/index.ts 内容：

打开本地文件查看：
```bash
cat supabase/functions/check-missed-check-ins/index.ts
```

### send-notification-email/index.ts 内容：

```bash
cat supabase/functions/send-notification-email/index.ts
```

---

完成后返回主流程配置 iOS 应用！
