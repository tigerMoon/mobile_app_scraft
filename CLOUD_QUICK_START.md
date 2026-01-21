# 云端快速启动（无需 Docker）

如果你想跳过 Docker 安装，可以直接使用云端 Supabase，5 分钟内完成设置。

## 步骤 1: 创建 Supabase 项目

1. 访问 https://supabase.com
2. 注册/登录账号（可用 GitHub 登录）
3. 点击 "New Project"
4. 填写：
   - **Name**: died-or-not
   - **Database Password**: 设置一个强密码（记住它）
   - **Region**: Northeast Asia (Seoul) - 最接近中国
5. 点击 "Create new project"
6. 等待 2 分钟项目创建完成

## 步骤 2: 获取项目凭证

项目创建完成后：

1. 点击左侧 "Settings" → "API"
2. 复制以下信息：
   ```
   Project URL: https://xxxxx.supabase.co
   anon public key: eyJhbGc...
   service_role key: eyJhbGc... (点击"Reveal"显示)
   ```

## 步骤 3: 登录并关联项目

```bash
cd /Users/tgmoon/github/died-or-not-scaffold

# 登录 Supabase
supabase login

# 关联到你的项目（Project Ref 在 URL 中: https://[这部分].supabase.co）
supabase link --project-ref xxxxx
```

## 步骤 4: 一键部署

```bash
./deploy.sh
```

脚本会自动：
- 推送数据库迁移（创建 users 和 check_ins 表）
- 部署 Edge Functions
- 显示部署结果

## 步骤 5: 配置 iOS 应用

编辑 `ios/DiedOrNot/Config.swift`：

```swift
enum Config {
    static let supabaseURL = URL(string: "https://xxxxx.supabase.co")!  // 你的 Project URL
    static let supabaseAnonKey = "eyJhbGc..."  // 你的 anon key
}
```

## 步骤 6: 配置定时任务（可选）

1. 在 Supabase 控制台点击 "SQL Editor"
2. 打开 `supabase/setup-cron.sql`
3. 替换以下内容：
   - `<YOUR_PROJECT>` → 你的项目 ID（如 xxxxx.supabase.co）
   - `<SERVICE_ROLE_KEY>` → 你的 service_role key
4. 执行 SQL

验证：
```sql
select * from cron.job;
```

## 步骤 7: 运行 iOS 应用

```bash
# 打开 Xcode
open ios/DiedOrNot

# 在 Xcode 中
# 1. 选择模拟器（iPhone 15 Pro）
# 2. 按 ⌘R 运行
# 3. 测试签到功能
```

## 步骤 8: 验证功能

1. **查看数据库**：
   - 打开 https://supabase.com/dashboard
   - 点击你的项目
   - Table Editor → users / check_ins
   - 应该能看到自动创建的匿名用户和签到记录

2. **测试 Edge Function**：
   ```bash
   curl -i --location --request POST \
     'https://xxxxx.supabase.co/functions/v1/check-missed-check-ins' \
     --header "Authorization: Bearer <你的 anon key>" \
     --header 'Content-Type: application/json'
   ```

## 优势

✅ **无需 Docker** - 不用下载几百 MB 的 Docker Desktop
✅ **立即可用** - 项目已经在云端运行
✅ **真实生产环境** - 直接在生产环境测试
✅ **全球 CDN** - Supabase 提供全球加速
✅ **免费额度** - 每月 500MB 数据库 + 2GB 文件存储

## 下一步

项目运行后，你可以：
- 在 iOS 应用中测试签到功能
- 在 Supabase Studio 查看数据
- 部署到 TestFlight 给朋友测试
- 根据需求扩展功能

---

**总用时：约 5-10 分钟（vs Docker 安装需要 30+ 分钟）**
