# 测试指南 · Testing Guide

本文档说明如何测试「死了么」应用的各项功能。

---

## 一、本地测试（使用 Supabase Local Development）

### 1.1 启动本地 Supabase

```bash
# 确保已安装 Docker
docker --version

# 启动本地 Supabase 实例
supabase start
```

这将启动：
- PostgreSQL 数据库（端口 54322）
- Supabase API（端口 54321）
- Supabase Studio（端口 54323）
- Inbucket 邮件测试服务器（端口 54324）

### 1.2 应用数据库迁移

```bash
supabase db reset
```

### 1.3 部署本地 Edge Functions

```bash
supabase functions serve
```

### 1.4 配置本地环境变量

更新 [.env](.env) 文件使用本地地址：

```
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=<从 supabase start 输出中获取>
SUPABASE_SERVICE_ROLE_KEY=<从 supabase start 输出中获取>
```

---

## 二、数据库测试

### 2.1 测试表结构

在 Supabase Studio（http://localhost:54323）中：

1. 打开 Table Editor
2. 验证以下表存在：
   - `users`（id, name, emergency_email, created_at）
   - `check_ins`（id, user_id, check_in_date, created_at）

### 2.2 测试 RLS 策略

```sql
-- 在 SQL Editor 中执行

-- 1. 创建测试用户
insert into auth.users (id, email)
values ('123e4567-e89b-12d3-a456-426614174000', 'test@example.com');

-- 2. 作为该用户插入数据（应该成功）
set local role authenticated;
set local request.jwt.claim.sub = '123e4567-e89b-12d3-a456-426614174000';

insert into users (id, name, emergency_email)
values ('123e4567-e89b-12d3-a456-426614174000', 'Test User', 'emergency@example.com');

-- 3. 尝试访问其他用户数据（应该失败）
select * from users where id != '123e4567-e89b-12d3-a456-426614174000';
```

### 2.3 测试唯一约束

```sql
-- 尝试重复签到（应该失败）
insert into check_ins (user_id, check_in_date)
values ('123e4567-e89b-12d3-a456-426614174000', current_date);

insert into check_ins (user_id, check_in_date)
values ('123e4567-e89b-12d3-a456-426614174000', current_date);
-- 第二次插入应该报错: duplicate key value violates unique constraint
```

---

## 三、Edge Functions 测试

### 3.1 测试 check-missed-check-ins 函数

**创建测试数据：**

```sql
-- 创建一个 3 天前签到的用户
insert into users (id, name, emergency_email)
values ('123e4567-e89b-12d3-a456-426614174000', 'Test User', 'test@example.com');

insert into check_ins (user_id, check_in_date)
values ('123e4567-e89b-12d3-a456-426614174000', current_date - interval '3 days');
```

**调用函数：**

```bash
curl -i --location --request POST \
  'http://localhost:54321/functions/v1/check-missed-check-ins' \
  --header 'Authorization: Bearer <ANON_KEY>' \
  --header 'Content-Type: application/json'
```

**预期结果：**

```json
{
  "success": true,
  "usersChecked": 1,
  "notificationsSent": 1,
  "timestamp": "2026-01-20T..."
}
```

### 3.2 测试 send-notification-email 函数

```bash
curl -i --location --request POST \
  'http://localhost:54321/functions/v1/send-notification-email' \
  --header 'Authorization: Bearer <ANON_KEY>' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Test User",
    "emergency_email": "test@example.com"
  }'
```

**预期结果：**

```json
{
  "success": true,
  "message": "Notification logged",
  "recipient": "test@example.com",
  "timestamp": "2026-01-20T..."
}
```

**查看邮件：**

访问 http://localhost:54324 查看 Inbucket 邮件测试界面。

---

## 四、iOS 应用测试

### 4.1 准备测试环境

1. 打开 Xcode
2. 打开 `ios/DiedOrNot` 项目
3. 配置 [Config.swift](ios/DiedOrNot/Config.swift) 使用本地 URL

```swift
enum Config {
    static let supabaseURL = URL(string: "http://localhost:54321")!
    static let supabaseAnonKey = "<本地 ANON_KEY>"
}
```

### 4.2 测试匿名登录

1. 运行应用（⌘R）
2. 查看 Xcode 控制台日志
3. 预期输出：`✅ 匿名登录成功: <UUID>`
4. 在 Supabase Studio → Authentication → Users 中验证用户创建

### 4.3 测试签到功能

**第一次签到：**

1. 点击"签到"按钮
2. 预期：按钮变为绿色，文字变为"✓ 今日已签到"
3. 在 Supabase Studio → Table Editor → check_ins 中验证记录

**防重复签到：**

1. 关闭并重新打开应用
2. 预期：按钮显示为"✓ 今日已签到"且禁用
3. 尝试点击，应该无响应

**第二天签到：**

1. 手动修改系统时间为明天（或修改数据库中的日期）
2. 重新打开应用
3. 预期：可以再次签到

### 4.4 测试错误处理

**断网测试：**

1. 关闭网络连接
2. 尝试签到
3. 预期：显示错误信息

**无效配置测试：**

1. 修改 Config.swift 使用无效的 URL
2. 运行应用
3. 预期：显示连接错误

---

## 五、定时任务测试

### 5.1 手动触发测试

```sql
-- 在 SQL Editor 中手动调用
select
  net.http_post(
    url := 'http://localhost:54321/functions/v1/check-missed-check-ins',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <SERVICE_ROLE_KEY>'
    )
  ) as request_id;
```

### 5.2 验证 Cron Job

```sql
-- 查看定时任务列表
select * from cron.job;

-- 查看执行历史
select * from cron.job_run_details
order by start_time desc
limit 10;
```

---

## 六、集成测试场景

### 场景 1：完整签到流程

1. 用户 A 安装并打开应用
2. 自动匿名登录
3. 用户 A 签到成功
4. 第二天再次签到成功
5. 第三天忘记签到
6. 定时任务检测到并记录通知

**验证步骤：**

```sql
-- 查看用户记录
select * from users where id = '<用户A的ID>';

-- 查看签到历史
select * from check_ins where user_id = '<用户A的ID>' order by check_in_date;

-- 验证间隔
select
  check_in_date,
  lead(check_in_date) over (order by check_in_date) as next_check_in,
  lead(check_in_date) over (order by check_in_date) - check_in_date as days_gap
from check_ins
where user_id = '<用户A的ID>';
```

### 场景 2：多用户并发签到

1. 创建 10 个测试用户
2. 同时进行签到
3. 验证所有记录正确创建
4. 验证 RLS 隔离正常工作

```bash
# 使用脚本批量测试
for i in {1..10}; do
  curl -X POST 'http://localhost:54321/rest/v1/check_ins' \
    -H "Authorization: Bearer <ANON_KEY>" \
    -H "Content-Type: application/json" \
    -d "{\"user_id\": \"user-$i\", \"check_in_date\": \"$(date +%Y-%m-%d)\"}" &
done
wait
```

---

## 七、性能测试

### 7.1 数据库查询性能

```sql
-- 创建大量测试数据
insert into check_ins (user_id, check_in_date)
select
  gen_random_uuid(),
  current_date - (random() * 365)::int
from generate_series(1, 10000);

-- 测试查询性能
explain analyze
select user_id, max(check_in_date) as last_check_in
from check_ins
group by user_id;
```

### 7.2 Edge Function 性能

```bash
# 使用 ab (Apache Bench) 进行压力测试
ab -n 100 -c 10 \
  -H "Authorization: Bearer <ANON_KEY>" \
  -H "Content-Type: application/json" \
  http://localhost:54321/functions/v1/check-missed-check-ins
```

---

## 八、测试清单

在正式部署前，确保完成以下测试：

- [ ] 数据库表结构正确
- [ ] RLS 策略工作正常
- [ ] 匿名登录功能正常
- [ ] 签到功能正常
- [ ] 防重复签到生效
- [ ] Edge Functions 正常运行
- [ ] 定时任务配置正确
- [ ] 日志记录完整
- [ ] 错误处理正确
- [ ] iOS 应用 UI 正常
- [ ] 多用户隔离正常
- [ ] 性能符合预期

---

## 九、调试技巧

### 查看实时日志

```bash
# Edge Functions 日志
supabase functions logs check-missed-check-ins --tail

# 数据库日志
supabase db logs --tail
```

### 常见错误排查

**"RLS policy violation"**
- 检查 auth.uid() 是否匹配 user_id
- 验证用户已登录

**"Unique constraint violation"**
- 预期行为：防止重复签到
- 检查前端是否正确检查签到状态

**"Function timeout"**
- 增加超时时间
- 优化查询性能
- 检查外部 API 调用

---

需要更多帮助？查看 [部署指南](DEPLOYMENT.md) 或 [README](README.md)。
